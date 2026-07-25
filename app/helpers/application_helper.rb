module ApplicationHelper
  def render_markdown(text)
    renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, autolink: true)
    renderer.render(text)
  end
end
