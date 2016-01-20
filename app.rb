require 'braintree'
require "rubygems"
require 'sinatra'

#Arrays full of nonces

NONCES = ["fake-valid-visa-nonce", "fake-valid-amex-nonce", "fake-valid-mastercard-nonce", "fake-valid-discover-nonce", 
          "fake-valid-jcb-nonce", "fake-valid-prepaid-nonce", "fake-valid-commercial-nonce", "fake-valid-durbin-regulated-nonce",
           "fake-valid-debit-nonce", "fake-valid-healthcare-nonce", "fake-valid-payroll-nonce", "fake-valid-country-of-issuance-usa-nonce",
           "fake-valid-country-of-issuance-cad-nonce", "fake-valid-issuing-bank-network-only-nonce", "fake-paypal-future-nonce"]

APPLE_PAY_NONCES = ["fake-apple-pay-amex-nonce", "fake-apple-pay-visa-nonce", "fake-apple-pay-mastercard-nonce"]

ANDROID_PAY_NONCES = ["fake-android-pay-visa-nonce", "fake-android-pay-mastercard-nonce", "fake-android-pay-amex-nonce", "fake-android-pay-discover-nonce"	]

get "/" do 
	erb :index
end

post "/prepopulate" do 

	p params

#Create a master array of all the nonces that will be iterated through	

@nonce_array = Array.new


  if params[:nonces] == "true" 
	@nonce_array += NONCES
   elsif params[:apple_pay] == "true"
	@nonce_array += APPLE_PAY_NONCES
   elsif params[:android_pay] == "true"
	@nonce_array += ANDROID_PAY_NONCES
   else
   "You didn't select any nonces to add"
  end

t_config = Braintree::Configuration.new(:environment => :sandbox, 
                               :merchant_id => params[:merchant_id], 
                                :public_key => params[:public_key], 
                               :private_key => params[:private_key])

t_gateway = Braintree::Gateway.new(t_config)

i = 0
while i < 50 do
 
#Create new customer id
  @number = Time.now.to_s.tr('^A-Za-z0-9', '') + rand(1000).to_s

  result = t_gateway.customer.create(
    :payment_method_nonce => @nonce_array[rand(@nonce_array.length-1)],
    :credit_card => {
      :billing_address => {
        :first_name => "Jen",
        :last_name => "Smith",
        :company => "Braintree",
        :street_address => "123 Address",
        :locality => "City",
        :region => "State",
        :postal_code => "12345"  
        },
        :options => {
        	:verify_card => true
        }
      })

  if result.success?
    transaction = t_gateway.transaction.sale(
      :amount => "#{rand(3000)}",
  	  :payment_method_token => result.customer.payment_methods[0].token,
  	  :options => {
  		:submit_for_settlement => true
    	})
  else
   p result.message
  end
  i +=1
 end
end


