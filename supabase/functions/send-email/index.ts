import { serve } from 'https://deno.land/std@0.131.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'
import { SmtpClient } from "https://deno.land/x/smtp@v0.7.0/mod.ts";

// Rate limiting configuration
const MAX_EMAILS_PER_MINUTE = 20;
const emailsSentTimestamps: number[] = [];

// Initialize SMTP client with environment variables
const smtpClient = new SmtpClient();

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    })
  }

  // Create a Supabase client
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') as string,
    Deno.env.get('SUPABASE_ANON_KEY') as string,
    {
      global: {
        headers: { Authorization: req.headers.get('Authorization')! },
      },
    }
  )

  // Get the session or return 401 if not authenticated
  const {
    data: { session },
  } = await supabaseClient.auth.getSession()

  if (!session) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }

  // Check rate limiting
  const now = Date.now();
  const oneMinuteAgo = now - 60000;

  // Remove timestamps older than 1 minute
  while (emailsSentTimestamps.length > 0 && emailsSentTimestamps[0] < oneMinuteAgo) {
    emailsSentTimestamps.shift();
  }

  // Check if rate limit exceeded
  if (emailsSentTimestamps.length >= MAX_EMAILS_PER_MINUTE) {
    return new Response(
      JSON.stringify({
        error: 'Rate limit exceeded. Try again later.'
      }),
      {
        status: 429,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Retry-After': '60',
        },
      }
    )
  }

  // Parse request body
  const { to, subject, html, attachments, tracking_id, cc, bcc } = await req.json()

  // Validate required fields
  if (!to || !subject || !html) {
    return new Response(
      JSON.stringify({
        error: 'Missing required fields: to, subject, and html are required'
      }),
      {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  }

  // Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(to)) {
    return new Response(
      JSON.stringify({
        error: 'Invalid email format'
      }),
      {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  }

  try {
    // Connect to SMTP server
    await smtpClient.connectTLS({
      hostname: Deno.env.get('SMTP_HOST') as string,
      port: parseInt(Deno.env.get('SMTP_PORT') as string),
      username: Deno.env.get('SMTP_USERNAME') as string,
      password: Deno.env.get('SMTP_PASSWORD') as string,
    });

    // Prepare email options
    const emailOptions: any = {
      from: Deno.env.get('EMAIL_FROM') as string,
      to: to,
      subject: subject,
      content: html,
      html: html,
    };

    // Add CC if provided
    if (cc) {
      emailOptions.cc = cc;
    }

    // Add BCC if provided
    if (bcc) {
      emailOptions.bcc = bcc;
    }

    // Add attachments if provided
    if (attachments && Array.isArray(attachments) && attachments.length > 0) {
      emailOptions.attachments = attachments.map((attachment: any) => ({
        filename: attachment.filename,
        content: attachment.content,
        contentType: attachment.contentType,
      }));
    }

    // Send email
    await smtpClient.send(emailOptions);

    // Add to rate limiting tracker
    emailsSentTimestamps.push(now);

    // Close connection
    await smtpClient.close();

    // Log email sent
    console.log(`Email sent to ${to}: ${subject}`);

    // Record email in database for tracking
    await supabaseClient
      .from('email_logs')
      .insert({
        user_id: session.user.id,
        recipient: to,
        subject: subject,
        sent_at: new Date().toISOString(),
        status: 'sent',
        tracking_id: tracking_id || null,
        cc: cc || null,
        bcc: bcc || null,
        has_attachments: attachments && attachments.length > 0,
      });

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Email sent successfully',
        tracking_id: tracking_id || null
      }),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  } catch (error) {
    console.error('Error sending email:', error);

    // Try to close the connection if it's still open
    try {
      await smtpClient.close();
    } catch (closeError) {
      console.error('Error closing SMTP connection:', closeError);
    }

    // Determine appropriate status code
    let statusCode = 500;
    let errorMessage = error.message || 'Unknown error';

    // Check for specific error types
    if (errorMessage.includes('authentication')) {
      statusCode = 401;
      errorMessage = 'SMTP authentication failed';
    } else if (errorMessage.includes('timeout')) {
      statusCode = 504;
      errorMessage = 'SMTP server timeout';
    } else if (errorMessage.includes('rate limit')) {
      statusCode = 429;
      errorMessage = 'Rate limit exceeded';
    }

    // Record failed email in database
    try {
      await supabaseClient
        .from('email_logs')
        .insert({
          user_id: session.user.id,
          recipient: to,
          subject: subject,
          sent_at: new Date().toISOString(),
          status: 'failed',
          error_message: errorMessage,
          tracking_id: tracking_id || null,
          cc: cc || null,
          bcc: bcc || null,
          has_attachments: attachments && attachments.length > 0,
        });
    } catch (dbError) {
      console.error('Error recording email failure in database:', dbError);
    }

    return new Response(
      JSON.stringify({
        error: errorMessage,
        tracking_id: tracking_id || null
      }),
      {
        status: statusCode,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  }
})
