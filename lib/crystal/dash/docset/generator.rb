require "crystal/dash/docset/generator/version"
require "open-uri"
require "nokogiri"
require "fileutils"

module Crystal::Dash::Docset::Generator
  class Generator
    attr_accessor :root_url
    attr_accessor :package_name

    def initialize(root_url: nil, package_name: nil)
      @root_url = root_url
      @package_name = package_name
      @path_to_this = File.expand_path(File.dirname(__FILE__))
    end

    def dashing_installed?
      system("hash dashing 2>/dev/null")
      $?.exitstatus == 0 ? true : false
    end

    def prepare_directory
      return nil if File.exist?(@package_name)
      Dir.mkdir(@package_name)
      Dir.chdir(@package_name)
    end

    def create_css
      Dir.mkdir("css")
      open("css/style.css", "wb") do |output|
        open("#{root_url}css/style.css") do |f|
          content = f.read
          # Remove unwanted styles
          content.gsub!(/left: 20%;/, "")
          content.gsub!(/right: 0;/, "")
          content.gsub!(/position: absolute;/, "")
          content.gsub!(/overflow: hidden;/, "")
          output.write(content)
        end
      end
    end

    def set_page_urls
      charset = nil
      root_html = open(@root_url) do |f|
        charset = f.charset
        f.read
      end
      root_doc = Nokogiri::HTML.parse(root_html, nil, charset)
      types_list = root_doc.css("div#types-list")
      @page_urls = types_list.css('a').inject([]) do |result, anchor|
        result << anchor[:href]
      end
    end

    def create_source_docs
      @page_urls.each do |url|
        yield url if block_given?
        charset = nil
        FileUtils.mkdir_p(File.dirname(url))
        open(url, "wb") do |output|
          html = open(URI.join(@root_url, url)) do |f|
            charset = f.charset
            f.read
          end
          doc = Nokogiri::HTML.parse(html, nil, charset)
          doc.css("div#types-list").remove
          doc.css("a.method-permalink").remove
          doc.css("script").remove
          doc.css("a").each do |node|
            node.remove if node.attr("href") == "https://travis-ci.org/manastech/crystal"
            node.remove if node.attr("href") == "https://www.bountysource.com/teams/crystal-lang/fundraisers/702-crystal-language"
          end
          output.write(doc.to_html)
        end
      end
    end

    def copy_dashing_config
      FileUtils.cp(File.join(@path_to_this, "dashing.json"), "dashing.json")
      FileUtils.cp(File.join(@path_to_this, "crystal-icon.png"), "crystal-icon.png")
    end

    def generate_dash_docset
      `dashing build #{@package_name}`
    end
  end
end
