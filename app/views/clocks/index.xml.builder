xml.chart do
  xml.series :title => user.name do
    for clock in @clocks
      xml.item :h => clock.created_at.to_formatted_s(:flash), :v => clock.time, :tip => "<b>#{clock.time / 100}</b> sec<br>#{clock.created_at.to_formatted_s(:long)}<br>#{clock.scramble}"
    end
  end
end