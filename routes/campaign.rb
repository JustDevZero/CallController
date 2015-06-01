class CallController < Sinatra::Application
 
  before /^(\/campaign)/ do
    unless user.is_admin?
      redirect "/"
    end
  end
  
  get '/campaign' do
    @campaigns = Campaign.all()
    @campaigntypes = CampaignType.all()
    erb :'campaign'
  end
    
  get '/campaign/edit/:id' do
    @campaign = Campaign.first(:id => params['id'])
    erb :'campaign_edit'
  end
  
  #~ get '/campaign/upload/:id' do
    #~ @campaign_id = params[:id]
    #~ erb :'campaign_upload'
  #~ end
  
  post '/campaign/add' do
    
    type = CampaignType.first(:id => params['campaign_type'])
    campaign = Campaign.first(:external_id => params['external_id'])
    if campaign.nil?
      Campaign.new(params[:external_id], type)
    end
    #~ Campaign.create(:external_id => params['external_id'], :campaign_type => params['campaign_type'])
    campaignlist = '/campaign'
    redirect to campaignlist
  end
  
  post '/campaign/edit' do
    campaign = Campaign.first(:id => params['id'])
    
    if !campaign.nil?
        
        if params['active'].nil?
          campaign.active = false
        else
          campaign.active = true
        end
        
        if params['external_id'].nil?
            campaign.external_id = params['campaign_type']
        end
        
        if params['campaign_type'].nil?
            campaign.campaign_type = params['campaign_type']
        end
        
        campaign.updated_at = Time.now
        campaign.save
        campaign.reload
    end
    campaignlist = '/campaign'
    redirect to campaignlist
  end
  
  post '/campaign/upload' do
    campaign = Campaign.first(:id => params['campaign_id'])
    
    if !campaign.nil?
        year_month_day = Time.now.strftime("%Y/%m")
        year_month_day_folder = 'uploads/imports' + year_month_day + '/'
        FileUtils.mkdir_p(year_month_day_folder)  unless File.exists?(year_month_folder)
        File.open(year_month_folder + params['myfile'][:filename], "w") do |campaign_file|
          campaign_file.write(params['myfile'][:tempfile].read) 
        end
      campaign.update(file => (year_month_folder + params['myfile'][:filename]))
    end
    redirect to '/origins'
  end
  
  post '/campaign/import' do
    campaign = Campaign.first(:id => params['campaign_id'])
    un = User.first(:username => session['username'])
    
    if !campaign.nil?
      #~ CampaignInstance.create(campaign.id, un, 'import')
      cn.process_import(un)
    end
    redirect to '/origins'
  end
  
end
