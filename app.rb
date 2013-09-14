require 'sinatra/base'
require 'uuidtools'
require 'plist'
require 'yaml'

class WebclipDistribution < Sinatra::Base

  MIME_TYPE = 'application/x-apple-aspen-config'

  PAYLOAD_TYPE_WEBCLIP = "com.apple.webClip.managed"
  PAYLOAD_TYPE_CONF = "Configuration"

  configure :production, :development do
    abs_path = File.join(File.dirname(__FILE__), 'conf.yaml')
    @@conf = YAML.load(File.read('conf.yaml'))
    p @@conf
  end

  get '/webclip' do
    content_type MIME_TYPE
    url_scheme = @@conf['url_scheme_prefix'] # may be replaced...
    content = webclip(url_scheme, @@conf['configuration'])
    Plist::Emit.dump(payload([content], @@conf['webclip']))
  end

  def payload(contents=[], conf)
    payload = Hash.new
    payload['PayloadVersion'] = 1
    payload['PayloadUUID'] = UUIDTools::UUID.random_create().to_s
    payload['PayloadOrganization'] = conf['organization']
    payload['PayloadType'] = PAYLOAD_TYPE_CONF
    payload['PayloadIdentifier'] = conf['identifier']
    payload['PayloadDisplayName'] = conf['display_name']
    payload['PayloadDescription'] = conf['description']
    payload['PayloadContent'] = contents
    payload
  end

  def webclip(url_scheme, conf)
    content_payload = Hash.new
    content_payload['PayloadVersion'] = 1
    content_payload['PayloadUUID'] = UUIDTools::UUID.random_create().to_s
    content_payload['PayloadOrganization'] = conf['organization']
    content_payload['PayloadIdentifier'] = conf['identifier']
    content_payload['PayloadType'] = PAYLOAD_TYPE_WEBCLIP
    content_payload['PayloadDisplayName'] = conf['display_name']
    content_payload['PayloadDescription'] = conf['description']
    content_payload['Icon'] = conf['icon'] if conf['icon']
    content_payload['Label'] = conf['label']
    content_payload['URL'] = url_scheme
    content_payload['IsRemovable'] = true
    content_payload['FullScreen'] = true
    content_payload['Precomposed'] = false
    content_payload
  end

end
