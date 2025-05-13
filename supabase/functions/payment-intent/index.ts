import { serve } from 'https://deno.land/std@0.131.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'
import Stripe from 'https://esm.sh/stripe@10.13.0'

// Initialize Stripe with the secret key from environment variables
const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') as string, {
  apiVersion: '2022-08-01',
})

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
  const { amount, currency, booking_id, payment_id } = await req.json()
  
  // Validate required fields
  if (!amount || !currency || !booking_id || !payment_id) {
    return new Response(
      JSON.stringify({ 
        error: 'Missing required fields: amount, currency, booking_id, and payment_id are required' 
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
    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency,
      automatic_payment_methods: {
        enabled: true,
      },
      metadata: {
        user_id: session.user.id,
        booking_id,
        payment_id,
      },
    })
    
    // Update payment with payment intent ID
    await supabaseClient
      .from('payments')
      .update({
        payment_intent_id: paymentIntent.id,
        status: 'processing',
        updated_at: new Date().toISOString(),
      })
      .eq('id', payment_id)
    
    return new Response(
      JSON.stringify({ 
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
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
    console.error('Error creating payment intent:', error)
    
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 400,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  }
})
