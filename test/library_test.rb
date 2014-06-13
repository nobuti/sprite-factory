require File.expand_path('test_case', File.dirname(__FILE__))

class SpriteFactory::LibraryTest < SpriteFactory::TestCase

  #--------------------------------------------------------------------------

  LIBRARIES = {
    :rmagick      => SpriteFactory::Library::RMagick,
    :chunkypng    => SpriteFactory::Library::ChunkyPng,
    :image_magick => SpriteFactory::Library::ImageMagick
  }

  #--------------------------------------------------------------------------

  LIBRARIES.each do |name, library| # use metaprogramming to define independent tests for each library

    define_method "test_load_regular_using_#{name}" do
      assert_images(REGULAR_INFO, library.load(REGULAR))
    end

    define_method "test_load_irregular_using_#{name}" do
      assert_images(IRREGULAR_INFO,  library.load(IRREGULAR))
    end

    define_method "test_create_using_#{name}" do
      with_clean_output do
        images = library.load(REGULAR)
        x = 0
        images.each do |image|
          image[:x] = x
          image[:y] = 0
          x = x + image[:width]
        end
        width  = images.map{|i| i[:width]}.inject(0){|n,w| n = n + w }
        height = images.map{|i| i[:height]}.max

        # Digest generation
        sum = Digest::MD5.new
        sum << LIBRARY_TEST_PATH
        sum << :horizontal.to_s
        images.each do |image|
          [:filename, :height, :width, :x, :y, :digest].each do |attr|
            sum << image[attr].to_s
          end
        end
        digest = sum.hexdigest[0...10]

        library.create(output_path("regular.horizontal-s#{digest}.png"), images, width, height)
        assert_reference_image("regular.horizontal-s#{digest}.png")
      end
    end

  end

  #--------------------------------------------------------------------------

  private

  def assert_images(expected, actual, msg = nil)
    assert_equal(expected.length, actual.length, "#{msg} - expected the same number of images")
    expected.length.times do |n|
      assert_equal(expected[n][:filename], actual[n][:filename], "#{msg} - unexpected filename at index #{n}")
      assert_equal(expected[n][:width],    actual[n][:width],    "#{msg} - unexpected width at index #{n}")
      assert_equal(expected[n][:height],   actual[n][:height],   "#{msg} - unexpected height at index #{n}")
    end
  end

  #----------------------------------------------------------------------------

end
