module ApplicationHelper
  def number_to_sat(value)
    number_to_currency(value.to_i, delimiter: ' ', precision: 0, unit: '') 
  end

  def format_date(date)
    date.strftime("%d.%m.%Y %H:%M")
  end
end
