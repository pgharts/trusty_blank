require "active_record"

class ActiveRecord::Base
  def self.create_or_update_for_site(options = {}, key = :name)
    options["site"] = Site.all(:first, :conditions => {:name => options["site"]})
    Page.current_site = options["site"]
    create_or_update options, key
  end

  def self.create_or_update_for_sites(options = {}, key = :name)
    options["sites"] = options["sites"].collect { |site_name| Site.all(:first, :conditions => {:name => site_name}) }
    create_or_update options, key
  end

  def self.create_or_update(options = {}, key = :id)
    record_from_db = first(:conditions=>{key => options[key.to_s]})
    return record_from_db if record_from_db && TrustySeedUtil.create_only
    options.delete "overwrite"
    record = record_from_db || new
    record.id = options["id"] if options["id"]
    record.update_attributes!(options)
    record
  end

  def existing_record?
    (not id.nil?)
  end

  def create_or_update_with_attributes! attributes
    return if TrustySeedUtil.create_only && existing_record?
    update_attributes!(attributes)
  end
end
