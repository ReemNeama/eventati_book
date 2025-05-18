import { serve } from 'https://deno.land/std@0.131.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'

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
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') as string
  )
  
  try {
    // Parse request body
    const { 
      recipient, 
      bounce_type, 
      bounce_reason, 
      tracking_id,
      related_message_id 
    } = await req.json()
    
    // Validate required fields
    if (!recipient) {
      return new Response(
        JSON.stringify({ 
          error: 'Missing required field: recipient is required' 
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
    
    // Find the original email in the logs
    let originalEmail;
    
    if (tracking_id) {
      // If tracking ID is provided, use it to find the email
      const { data: emailData, error: emailError } = await supabaseClient
        .from('email_logs')
        .select('*')
        .eq('tracking_id', tracking_id)
        .order('sent_at', { ascending: false })
        .limit(1);
        
      if (emailError) {
        console.error('Error finding original email by tracking ID:', emailError);
      } else if (emailData && emailData.length > 0) {
        originalEmail = emailData[0];
      }
    }
    
    if (!originalEmail && related_message_id) {
      // If tracking ID didn't work but we have a message ID, try that
      const { data: emailData, error: emailError } = await supabaseClient
        .from('email_logs')
        .select('*')
        .eq('message_id', related_message_id)
        .order('sent_at', { ascending: false })
        .limit(1);
        
      if (emailError) {
        console.error('Error finding original email by message ID:', emailError);
      } else if (emailData && emailData.length > 0) {
        originalEmail = emailData[0];
      }
    }
    
    if (!originalEmail) {
      // If we still don't have the original email, try by recipient
      const { data: emailData, error: emailError } = await supabaseClient
        .from('email_logs')
        .select('*')
        .eq('recipient', recipient)
        .order('sent_at', { ascending: false })
        .limit(1);
        
      if (emailError) {
        console.error('Error finding original email by recipient:', emailError);
      } else if (emailData && emailData.length > 0) {
        originalEmail = emailData[0];
      }
    }
    
    // Record the bounce in the database
    const { data, error } = await supabaseClient
      .from('email_bounces')
      .insert({
        recipient: recipient,
        bounce_type: bounce_type || 'unknown',
        bounce_reason: bounce_reason || 'unknown',
        tracking_id: tracking_id || null,
        related_message_id: related_message_id || null,
        original_email_id: originalEmail?.id || null,
        received_at: new Date().toISOString(),
      });
      
    if (error) {
      console.error('Error recording email bounce:', error);
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
    
    // If we found the original email, update its status
    if (originalEmail) {
      const { error: updateError } = await supabaseClient
        .from('email_logs')
        .update({
          status: 'bounced',
          error_message: bounce_reason || 'Email bounced',
          updated_at: new Date().toISOString(),
        })
        .eq('id', originalEmail.id);
        
      if (updateError) {
        console.error('Error updating original email status:', updateError);
      }
    }
    
    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Email bounce recorded successfully' 
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
    console.error('Error handling email bounce:', error);
    
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
