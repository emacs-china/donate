require 'csv'
require 'erb'

csv_path = './data.csv'
csv_str = File.read(csv_path)
csv = CSV.new(csv_str).to_a

total_amount = 0
total_expense = 0

template_donation = Q%{
<tr>
  <td class="org-left">
    <%= date %>
  </td>
  <td class="org-left">
    <% if link.empty? %
      <%= person %>
    <% else %>
      <a href="<%= link %>"><%= person %></a>
    <% end %>
  </td>
  <td class="org-left">
    <%= amount %>
    (<%= platform %>)
  </td>
</tr>
}

template_expense = p %{

}

output_donation = ''
output_expense = ''

csv.each_with_index do |record, index|
  next if index.zero?

  date = record[0]
  person = record[1]
  link = record[2]
  amount = record[3]
  platform = record[4]
  purpose = record[5]
  remark = record[6]

  if amount.to_f > 0
    total_amount += amount.to_f

    renderer = ERB.new(template_donation)
    puts output = renderer.result

  else
    total_expense += amount.to_f
  end
end



puts total_expense.abs
puts total_amount
