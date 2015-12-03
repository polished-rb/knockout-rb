module OpalKnockout
  module KnockoutHelpers
    def knockout(partial=nil, subview:nil, bind_as:nil)
      if partial
        render(partial: 'knockout/' + partial.to_s)
      elsif subview
        subview_with = bind_as || subview.split('/').last
        content_tag(:div, 'data-bind' => "with: #{subview_with}") do
          render(partial: 'knockout/' + subview.to_s)
        end
      end
    end
  end
end