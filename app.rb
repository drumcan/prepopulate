require 'braintree'
require "rubygems"
require 'sinatra'


get "/" do 
	erb :index
end

post "/prepopulate" do 

p_config = Braintree::Configuration.new(:environment => :sandbox, 
                               :merchant_id => params[:merchant_id], 
                                :public_key => params[:public_key], 
                               :private_key => params[:private_key])

p_gateway = Braintree::Gateway.new(p_config)
 


result = p_gateway	.transaction.sale(
  :amount => "100.00",
  :payment_method_nonce => "fake-valid-nonce",
  :options => {
  	:submit_for_settlement => true,
    :store_in_vault_on_success => true, 
    
  }
)

if result.success?
  content_type :json
  return {:result => "Success ID: #{result.transaction.id}"}.to_json
  else
   p result.message
  end
end