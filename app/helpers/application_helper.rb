module ApplicationHelper
  def title(text)
    content_for :title, text
  end

  def meta_tag(tag, text)
    content_for :"meta_#{tag}", text
  end

  def yield_meta_tag(tag, default_text='')
    content_for?("meta_#{tag}") ? content_for?("meta_#{tag}") : default_text
  end

  def og_title(og_title)
    content_for :og_title, og_title
  end

  def og_url(og_url)
    content_for :og_url, og_url
  end

  def og_description(description)
    content_for :og_description, description
  end

  def og_image(image)
    content_for :og_image, image
  end

  def reading_color(readingCode)
    case readingCode
      when 1
        color = 'red'
      when 4
        color = 'red'
      when 7
        color = 'blue'
      when 8
        color = 'red'
      when 10
        color = 'red'
      when 11
        ccolor = 'red'
      when 13
        color = 'red'
      when 15
        color = 'red'
      when 17
        color = 'red'
      when 18
        color = 'red'
      when 19
        color = 'red'
    end
    return "color:"+color
  end

end
