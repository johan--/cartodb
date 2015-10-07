# encoding: utf-8

require_relative '../../../services/datasources/lib/datasources'

# @see DB table 'synchronization_oauths'
class SynchronizationOauth < Sequel::Model

  many_to_one :user

  PUBLIC_ATTRIBUTES = [
    :user_id,
    :service,
    :token
  ]

  def public_values
    Hash[PUBLIC_ATTRIBUTES.map{ |k| [k, (self.send(k) rescue self[k].to_s)] }]
  end

  def validate
    super

    validates_presence :token

    if new?
      existing_oauth = SynchronizationOauth.filter(
        user_id:  user_id,
        service:  service
      ).first
      errors.add(:user_id, " already has an oauth token created for service #{:service}") unless existing_oauth.nil?
    else
      errors.add(:user_id, ' cannot modify user, only token') if changed_columns.include?(:user_id)
      errors.add(:service, ' cannot modify service, only token') if changed_columns.include?(:service)
    end
  end

  def before_save
    super
    self.updated_at = Time.now
  end

  def ==(oauth_object)
    return false unless oauth_object
    id == oauth_object.id
  end

  def get_service_datasource
    user = User.where(id: user_id).first
    datasource =
    CartoDB::Datasources::DatasourcesFactory.get_datasource(service, user,
                                                            http_timeout: ::DataImport.http_timeout_for(user)
                                                           )
    datasource.token = token unless datasource.nil?
    datasource
  end

end
