import { serve } from 'https://deno.land/std@0.131.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    })
  }
  
  // Create a Supabase client
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') as string,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') as string
  )
  
  // Handle GET requests (user clicking unsubscribe link)
  if (req.method === 'GET') {
    const url = new URL(req.url);
    const email = url.searchParams.get('email');
    const token = url.searchParams.get('token');
    const type = url.searchParams.get('type') || 'all';
    
    if (!email || !token) {
      return new Response(
        `<html>
          <head>
            <title>Invalid Unsubscribe Request</title>
            <style>
              body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
              .container { max-width: 600px; margin: 0 auto; }
              h1 { color: #333; }
              .error { color: #cc0000; }
            </style>
          </head>
          <body>
            <div class="container">
              <h1>Invalid Unsubscribe Request</h1>
              <p class="error">Missing required parameters. Please use the unsubscribe link provided in the email.</p>
            </div>
          </body>
        </html>`,
        {
          status: 400,
          headers: { 'Content-Type': 'text/html' },
        }
      )
    }
    
    // Verify the token
    // In a real implementation, you would use a proper token verification method
    // This is a simplified example
    const expectedToken = btoa(`${email}:${Deno.env.get('UNSUBSCRIBE_SECRET')}`);
    
    if (token !== expectedToken) {
      return new Response(
        `<html>
          <head>
            <title>Invalid Unsubscribe Token</title>
            <style>
              body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
              .container { max-width: 600px; margin: 0 auto; }
              h1 { color: #333; }
              .error { color: #cc0000; }
            </style>
          </head>
          <body>
            <div class="container">
              <h1>Invalid Unsubscribe Token</h1>
              <p class="error">The unsubscribe link is invalid or has expired.</p>
            </div>
          </body>
        </html>`,
        {
          status: 400,
          headers: { 'Content-Type': 'text/html' },
        }
      )
    }
    
    try {
      // Record the unsubscribe request
      await supabaseClient
        .from('email_unsubscribes')
        .upsert({
          email: email,
          unsubscribe_type: type,
          unsubscribed_at: new Date().toISOString(),
        });
      
      return new Response(
        `<html>
          <head>
            <title>Unsubscribe Successful</title>
            <style>
              body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
              .container { max-width: 600px; margin: 0 auto; }
              h1 { color: #333; }
              .success { color: #007700; }
            </style>
          </head>
          <body>
            <div class="container">
              <h1>Unsubscribe Successful</h1>
              <p class="success">You have been successfully unsubscribed from ${type === 'all' ? 'all emails' : type + ' emails'}.</p>
              <p>If you change your mind, you can update your email preferences in your account settings.</p>
            </div>
          </body>
        </html>`,
        {
          status: 200,
          headers: { 'Content-Type': 'text/html' },
        }
      )
    } catch (error) {
      console.error('Error processing unsubscribe request:', error);
      
      return new Response(
        `<html>
          <head>
            <title>Unsubscribe Error</title>
            <style>
              body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
              .container { max-width: 600px; margin: 0 auto; }
              h1 { color: #333; }
              .error { color: #cc0000; }
            </style>
          </head>
          <body>
            <div class="container">
              <h1>Unsubscribe Error</h1>
              <p class="error">There was an error processing your unsubscribe request. Please try again later.</p>
            </div>
          </body>
        </html>`,
        {
          status: 500,
          headers: { 'Content-Type': 'text/html' },
        }
      )
    }
  }
  
  // Handle POST requests (API calls)
  if (req.method === 'POST') {
    try {
      const { email, type } = await req.json();
      
      if (!email) {
        return new Response(
          JSON.stringify({ error: 'Email is required' }),
          {
            status: 400,
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          }
        )
      }
      
      // Record the unsubscribe request
      const { error } = await supabaseClient
        .from('email_unsubscribes')
        .upsert({
          email: email,
          unsubscribe_type: type || 'all',
          unsubscribed_at: new Date().toISOString(),
        });
        
      if (error) {
        throw error;
      }
      
      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'Unsubscribe request processed successfully' 
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
      console.error('Error processing unsubscribe request:', error);
      
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
  }
  
  // Handle unsupported methods
  return new Response(
    JSON.stringify({ error: 'Method not allowed' }),
    {
      status: 405,
      headers: { 
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Allow': 'GET, POST, OPTIONS',
      },
    }
  )
})
