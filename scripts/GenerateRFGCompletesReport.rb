require 'csv'

CSV.open('RFGcompletes', 'w') do |csv|
#  csv << "Titles"
  User.where("created_at > ?", (Time.now.midnight - 31.day)).each do |m|
    print "created_at", m.created_at
    print "m.SurveysCompleted: ", m.SurveysCompleted
    print "m.SurveysCompleted.length: ", m.SurveysCompleted.length
    puts
    if m.SurveysCompleted.length > 0 then
      if m.SurveysCompleted.flatten(2).include?("RFG") == true then
        csv << m.created_at.to_s
        csv << m.SurveysCompleted.to_a.flatten
        puts "added a new row"
      else
      end
    else
    end
  end
end