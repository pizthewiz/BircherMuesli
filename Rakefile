
require 'rake'

GIT = '/usr/bin/git'
BUNDLE_IDENTIFIER_KEY = 'CFBundleIdentifier'
BUNDLE_VERSION_NUMBER_KEY = 'CFBundleVersion'
BUNDLE_VERSION_STRING_KEY = 'CFBundleShortVersionString'
HEAD_REVISION_KEY = 'com.chordedconstructions.ProjectHEADRevision'

ARCHIVE_FILES = %w(README.markdown TODO CHANGELOG Device\ Explorer.qtz)
ARCHIVE_NAME = 'BircherMuesli'

# helpers
def build_number
  `#{GIT} log --pretty=format:'' | wc -l`.scan(/\d/).to_s
end
def build_string
  string = `#{GIT} describe --dirty`
  # ignore leading 'v' if it is there
  string.sub(/^[v]+/, '').strip unless string.nil? or string.empty?
end
def head_rev
  rev = `#{GIT} rev-parse HEAD`
  rev.strip unless rev.nil? or rev.empty?
end


# tasks
desc 'update Info.plist build version number and string from git'
task :update_bundle_version, [:build_dir, :infoplist_path] do |t, args|
  # based on
  # http://github.com/guicocoa/xcode-git-cfbundleversion/
  # http://github.com/digdog/xcode-git-cfbundleversion/
  # http://github.com/jsallis/xcode-git-versioner
  # http://github.com/juretta/iphone-project-tools/tree/v1.0.3
  require 'rubygems'
  begin
      require 'Plist'
  rescue LoadError => e
      puts "ERROR - cannot find gem 'Plist'"
      exit 1
  end

  build_dir = ENV['BUILT_PRODUCTS_DIR'] || args.build_dir
  infoplist_path = ENV['INFOPLIST_PATH'] || args.infoplist_path
  unless !build_dir.nil? and !infoplist_path.nil?
    puts "ERROR - requires build directory and infoplist path via args or 'BUILT_PRODUCTS_DIR' and 'INFOPLIST_PATH'"
    exit 1
  end

  product_plist = File.join(build_dir, infoplist_path)
  unless File.file? product_plist
    puts "ERROR - cannot find build product's info plist at path '#{product_plist}'"
    exit 1
  end

  synthesized_build_number = build_number
  synthesized_build_string = build_string

  # update product plist
  `/usr/bin/plutil -convert xml1 \"#{product_plist}\"`
  info = Plist::parse_xml(product_plist)
  if info
      info[BUNDLE_VERSION_NUMBER_KEY] = synthesized_build_number
      info[BUNDLE_VERSION_STRING_KEY] = synthesized_build_string unless synthesized_build_string.empty?
      info[HEAD_REVISION_KEY] = head_rev
      info.save_plist(product_plist)
  end
  `/usr/bin/plutil -convert binary1 \"#{product_plist}\"`

  # friendly output
  puts "updated '#{BUNDLE_VERSION_NUMBER_KEY}' in '#{File.basename(infoplist_path)}' to #{synthesized_build_number}"
  puts "updated '#{BUNDLE_VERSION_STRING_KEY}' in '#{File.basename(infoplist_path)}' to #{synthesized_build_string}" unless synthesized_build_string.empty?
end

desc 'create archive of application and resources for distribution'
task :create_archive, [:build_path, :product_name] do |t, args|
  build_dir = ENV['BUILT_PRODUCTS_DIR'] || args.build_path
  product_name = ENV['FULL_PRODUCT_NAME'] || args.product_name
  unless !build_dir.nil? && !product_name.nil?
    puts "ERROR - requires build directory and product name via args or 'BUILT_PRODUCTS_DIR' and 'FULL_PRODUCT_NAME'"
    exit 1
  end

  base_name = File.basename(product_name, File.extname(product_name))
  dir_name = "#{base_name}-#{build_string}"
  FileUtils.rm_r(Dir.glob("#{dir_name}/"), {:secure => true}) if File.exists? dir_name
  FileUtils.mkdir dir_name unless File.exists? dir_name

  # TODO - this should only be the product itself not the whole directory
  %x{ ditto "#{build_dir}" "#{dir_name}"  }
  FileUtils.cp ARCHIVE_FILES, dir_name

  # TODO - probably want to zap dot files too
  %x{ zip -r -y "#{dir_name}.zip" "#{dir_name}" }
  FileUtils.rm_r(dir_name, {:secure => true})

  # %x{ open . }
end

desc 'delete archive'
task :clobber_archive do
  Dir.glob(ARCHIVE_NAME+"-[0-9].[0-9].[0-9]*.zip").each do |f|
    puts "removing '#{f}'"
    FileUtils.rm_r(f, {:secure => true})
  end
end
