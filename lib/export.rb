def export(requests)
  csv_string = CSV.generate do |csv|
    csv << requests.column_names
    requests.each do |f|
      csv << f.attributes.values.clone #clone not absolutely neccessary.
    end
  end
    # send it to the browser with proper headers
    send_data csv_string,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=BIRCH_Requests-#{Time.now.strftime("%Y%m%d")}.csv"
end