import { serve } from 'https://deno.land/std@0.131.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'
import { SmtpClient } from "https://deno.land/x/smtp@v0.7.0/mod.ts";

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
  
  // Parse request body
  const { to, subject, html } = await req.json()
  
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
  
  try {
    // Connect to SMTP server
    await smtpClient.connectTLS({
      hostname: Deno.env.get('SMTP_HOST') as string,
      port: parseInt(Deno.env.get('SMTP_PORT') as string),
      username: Deno.env.get('SMTP_USERNAME') as string,
      password: Deno.env.get('SMTP_PASSWORD') as string,
    });
    
    // Send email
    await smtpClient.send({
      from: Deno.env.get('EMAIL_FROM') as string,
      to: to,
      subject: subject,
      content: html,
      html: html,
    });
    
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
      });
    
    return new Response(
      JSON.stringify({ success: true, message: 'Email sent successfully' }),
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
    
    // Record failed email in database
    await supabaseClient
      .from('email_logs')
      .insert({
        user_id: session.user.id,
        recipient: to,
        subject: subject,
        sent_at: new Date().toISOString(),
        status: 'failed',
        error_message: error.message,
      });
    
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  }
})
