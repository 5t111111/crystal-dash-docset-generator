require 'test_helper'
require 'fileutils'

class Crystal::Dash::Docset::GeneratorTest < Minitest::Test
  i_suck_and_my_tests_are_order_dependent!

  def setup
    Dir.chdir(File.join(File.dirname(__FILE__), "test_data"))
    @generator = Crystal::Dash::Docset::Generator::Generator.new(
      root_url: "http://crystal-lang.org/api/",
      package_name: "crystal"
    )
    if File.exist?(@generator.package_name)
      FileUtils.rm_rf(@generator.package_name)
    end
  end

  def teardown
    if File.exist?(@generator.package_name)
      FileUtils.rm_rf(@generator.package_name)
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::Crystal::Dash::Docset::Generator::VERSION
  end

  def test_it_has_root_url
    assert_equal @generator.root_url, "http://crystal-lang.org/api/"
  end

  def test_it_has_package_name
    assert_equal @generator.package_name, "crystal"
  end

  def test_that_it_has_output_directory
    expected = File.join(File.expand_path(File.dirname(__FILE__)), "test_data", @generator.package_name)
    assert_equal expected, @generator.output_directory
  end

  def test_prepare_directory_returns_nil_if_already_exist
    Dir.mkdir(@generator.package_name)
    assert_nil @generator.prepare_directory
  end

  def test_prepare_directory_works
    assert_equal 0, @generator.prepare_directory
    assert_equal File.join(File.dirname(__FILE__), "test_data", @generator.package_name), Dir.pwd
    Dir.chdir(File.join(File.dirname(__FILE__), "test_data"))
    assert File.directory?(@generator.package_name)
  end

  def test_create_css
    @generator.prepare_directory
    @generator.create_css
    assert File.file?(File.join(File.dirname(__FILE__), "test_data", @generator.package_name, "css", "style.css"))
  end

  def test_set_page_urls
    urls = @generator.set_page_urls
    assert_equal ["index.html", "toplevel.html"], urls[0..1]
  end

  def test_create_source_docs
    @generator.prepare_directory
    @generator.create_css
    @generator.set_page_urls
    @generator.create_source_docs
  end
end
