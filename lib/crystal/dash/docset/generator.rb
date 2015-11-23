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
        puts url
        charset = nil
        # puts URI.join(@root_url, url)
        FileUtils.mkdir_p(File.dirname(url))
        open(url, "wb") do |output|
          html = open(URI.join(@root_url, url)) do |f|
            charset = f.charset
            f.read
          end
          doc = Nokogiri::HTML.parse(html, nil, charset)
          doc.css("div#types-list").remove
          output.write(doc.to_html)
        end
      end
    end
  end
end

@generator = Crystal::Dash::Docset::Generator::Generator.new(
  root_url: "http://crystal-lang.org/api/",
  package_name: "crystal"
)
@generator.prepare_directory
@generator.create_css
@generator.set_page_urls
@generator.create_source_docs
