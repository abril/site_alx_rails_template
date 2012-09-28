if Rails.env.development? || Rails.env.test?
  SiteEngine::Common::Yml.instance_eval do
    alias :read_from_config_original :read_from_config

    def read_from_config(file, env='')
      read_from_config_original(file, 'dev')
    end
  end
end
