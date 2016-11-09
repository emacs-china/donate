require 'csv'
require 'erb'

csv_path = './data.csv'
csv_str = File.read(csv_path)
csv = CSV.new(csv_str).to_a

total_amount = 0
total_expense = 0

template_donation = %Q{
<tr>
  <td class="org-left">
    <%= date %>
  </td>
  <td class="org-left">
    <% if link == nil %>
      <%= person %>
    <% else %>
      <a href="<%= link %>"><%= person %></a>
    <% end %>
  </td>
  <td class="org-left">
    <%= amount %>
    <% unless platform == nil %>
      (<%= platform %>)
    <% end %>
  </td>
</tr>
}

template_md_donation = %Q{| <%= date %> | [<%= person %>](<%= link %>) | <%= amount %> |
}

template_expense = %Q{
<tr>
  <td class="org-left">
    <%= date %>
  </td>
  <td class="org-left">
    <% if link == nil %>
      <%= person %>
    <% else %>
      <a href="<%= link %>"><%= person %></a>
    <% end %>
  </td>
  <td class="org-left">
    <%= amount %>
    <% unless platform == nil %>
      (<%= platform %>)
    <% end %>
  </td>
  <td class="org-left">
    <%= purpose %>
  </td>
  <td class="org-left">
    <%= remark %>
  </td>
</tr>
}

template_md_expense = %Q{| <%= date %> | [<%= person %>](<%= link %>) | <%= amount %> | <%= purpose %> | <%= remark %> |
}


output_donation = ''
output_expense = ''
output_md_donation = ''
output_md_expense = ''

csv.each_with_index do |record, index|
  next if index.zero?

  b = binding
  date = record[0]
  b.local_variable_set(:date, date)
  person = record[1]
  b.local_variable_set(:person, person)
  link = record[2]
  b.local_variable_set(:link, link)
  amount = record[3]
  b.local_variable_set(:amount, amount)
  platform = record[4]
  b.local_variable_set(:platform, platform)
  purpose = record[5]
  b.local_variable_set(:purpose, purpose)
  remark = record[6]
  b.local_variable_set(:remark, remark)

  if amount.to_f > 0
    total_amount += amount.to_f
    renderer = ERB.new(template_donation)
    renderer_md = ERB.new(template_md_donation)
    output_donation << renderer.result(b)
    output_md_donation << renderer_md.result(b)
  else
    total_expense += amount.to_f
    renderer = ERB.new(template_expense)
    renderer_md = ERB.new(template_md_expense)
    output_expense << renderer.result(b)
    output_md_expense << renderer_md.result(b)
  end
end

page_outline = ERB.new(File.new('./temp.html.erb').read)
b = binding
b.local_variable_set(:total_amount, total_amount)
b.local_variable_set(:total_expense, total_expense)
b.local_variable_set(:list_donation, output_donation)
b.local_variable_set(:list_expense, output_expense)

File.open('./index.html', 'w') { |f| f.write(page_outline.result(b)) }

page_md_outline = ERB.new(File.new('./temp.md.erb').read)

b.local_variable_set(:list_donation_md, output_md_donation)
b.local_variable_set(:list_expense_md, output_md_expense)

File.open('./README.md', 'w') { |f| f.write(page_md_outline.result(b)) }

# Commit and push to Github
#
%x(
git add --all
git commit -m "Update"
git push origin gh-pages
)
