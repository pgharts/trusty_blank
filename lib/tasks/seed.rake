namespace :trusty do
  require File.dirname(__FILE__) + '/active_record_util'
  require File.dirname(__FILE__) + '/trusty_seed_util'

  def load_yaml_for(file_name)
    require 'yaml'
    fixtures_dir = "#{File.expand_path(File.dirname(__FILE__)+"../../../db/fixtures")}"
    YAML::load(File.open(File.join(fixtures_dir, file_name+".yml")))
  end

  def load_content_from(dir, file_name, site_name)
    site_folder = site_name.downcase.gsub(/ /, '_')
    content_dir = "#{File.expand_path(File.dirname(__FILE__)+"../../../db/content")}"

    file_path_with_site_id = content_dir + "/#{dir}/" + "#{site_folder}/" + "#{file_name}.html"
    file_path = content_dir + "/#{dir}/" + "#{file_name}.html"
    if File.exists?(file_path_with_site_id)
      puts "Seed:Log: found site specific layout for #{file_name} and site #{site_folder}"
      return File.open(file_path_with_site_id, 'r').read
    elsif File.exists?(file_path)
      return File.open(file_path, 'r').read
    else
      return ""
    end

  end

  def id_for_site(site_name)
    load_yaml_for("sites")[site_name]["id"]
  end

  def find_layout_for(layout_name, site_id, create_new = false)
    return Layout.find_without_site(:first, :conditions => {:name => layout_name, :site_id => site_id}) ||
        (create_new ? Layout.new : raise(">>>> Seed:Error: layout #{layout_name} not found for site id #{site_id}"))
  end

  def sort(hash, on_parameter)
    hash.sort do |first, second|
      first_value = first[1]
      second_value = second[1]
      first_value[on_parameter] <=> second_value[on_parameter]
    end
  end

  def set_current_site(site_id)
    temp_site = Site.new
    temp_site.id = site_id
    Page.current_site = temp_site
  end

  def update_page_parent(page_hash, current_parent)
    page = find_by_slug_hierarchy([current_parent, page_hash["slug"]])
    if page
      new_parent = find_by_slug_hierarchy(page_hash['parent'].split('/'))
      page.parent = new_parent
      puts "Updating parent of #{page['title']} to #{new_parent.title}"
      page.save
    end
  end

  def create_or_update_page(page_hash, site_id = nil, klass = Page)
    page_hash["layout"] = find_layout_for page_hash["layout"], site_id if page_hash["layout"]
    page_hash["parent"] = find_by_slug_hierarchy(page_hash["parent"].split('/')) if page_hash["parent"]

    page = (page_hash["parent"].nil? ? find_by_slug_hierarchy([page_hash["slug"]]) : find_by_slug_hierarchy([page_hash["slug"]], page_hash["parent"])) || klass.new
    page.create_or_update_with_attributes!(page_hash)
    page
  end

  def find_by_slug_hierarchy(slugs, current_page = Page.find_by_slug("/"))
    return current_page if (slugs.nil? || slugs.empty?)
    if (slugs[0] == "/")
      slugs.shift
      find_by_slug_hierarchy(slugs, current_page)
    else
      find_by_slug_hierarchy(slugs, Page.first(:conditions => {:slug => slugs.shift, :parent_id => current_page}))
    end
  end

  desc "Seed the convoy app"
  task :seed, [:overwrite_existing] => [:environment, :set_seed_mode,
                                              'seed:layouts', 'seed:pages:root',
                                              'seed:pages:home','seed:sites', 'seed:verify']

  task :set_seed_mode do |t, args|
    create_only = args.overwrite_existing == "create_only" ? true : false
    TrustySeedUtil.create_only = create_only
    puts "<<<<< Seed is running in #{TrustySeedUtil.create_only ? 'create only mode' : 'create and update mode'} >>>>>"
  end

  namespace :seed do
    desc "Seeds layouts for each site into the DB"
    task :layouts => :environment do
      load_yaml_for("sites").each do |t_site, site|
        load_yaml_for("layouts").each do |t_layout, layout|
          layout["content"] = load_content_from("layouts", layout["name"], site["name"])
          #layout["mobile_content"] = load_content_from("m/layouts", layout["name"], site["name"])
          set_current_site(site["id"])
          newlayout = find_layout_for layout["name"], site["id"], true
          layout["site_id"] = site["id"]
          newlayout.create_or_update_with_attributes!(layout)
        end
      end
    end

    namespace :pages do
      desc "setup the Root page which is a parent to everyone"
      task :root => :environment do
        master = load_yaml_for("home_pages")["Cultural District"]
        create_or_update_page(master, id_for_site(master["title"]))
      end

      desc "Seed homepages"
      task :home => :environment do
        load_yaml_for("home_pages").each do |index, page|
          create_or_update_page(page, id_for_site(page["title"]))
        end
      end
    end

    desc "Seeds plain sites without users or pages into the DB"
    task :sites => :environment do
      pages = load_yaml_for("home_pages")
      sites = sort(load_yaml_for("sites"), "position")
      sites.each do |t, site|
        site['homepage'] = site["name"] == 'default_site' ? Page.find(1) : find_by_slug_hierarchy([pages[site["name"]]["slug"]])
        site['base_domain'] += Rails.configuration.domain
        Site.create_or_update(site)
      end
    end

    desc "Seed verification"
    task :verify => :environment do
      sites = Site.all(:conditions => ["homepage_id IS NOT NULL and position IS NOT NULL"])
      puts "Seed:Log: No of sites in database #{sites.size}"
      raise "Seed:Error: atleast 11 sites should exist in database" if sites.size <3


      root_page = Page.all(:conditions => ["parent_id IS NULL"])
      puts "Seed:Log: No of root page(s) in database #{root_page.size}"
      raise "Seed:Error: only one root page should exist without parent id" if root_page.size > 1
    end

  end
end

