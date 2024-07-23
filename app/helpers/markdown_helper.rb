module MarkdownHelper
  def markdown(text)
    options = {
      filter_html: true,
      hard_wrap: true, 
      space_after_headers: true,
    }

    extensions = {
      link_attributes: { rel: 'nofollow', taget: '_blank' },
      fenced_code_blocks: true,
      no_intra_emphasis: true,
      autolink: true,
      tables: true,
      lax_spacing: true,
      underline: true,
      highlight: true,
      quote: true, 
      footnotes: true
    }

    unless @markdown
      renderer = Redcarpet::Render::HTML.new(options)
      @markdown = Redcarpet::Markdown.new(renderer, extensions)
    end

    @markdown.render(text).html_safe
  end
end
