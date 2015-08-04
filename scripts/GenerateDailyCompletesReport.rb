require 'csv'

begin
  timetorepeat = true

  CSV.open('Reports/Dailycompletes', 'a') do |csv|
    #  csv << "Titles"
    User.where("created_at > ?", (Time.now.midnight - 91.day)).each do |m|
      print "m.SurveysCompleted: ", m.SurveysCompleted
      puts
      if m.SurveysCompleted.length > 0 then
        csv << m.SurveysCompleted.to_a.flatten
        puts "added a new row"
      else
      end
    end
  end
  
  sleep (1440.minutes)
end while timetorepeat