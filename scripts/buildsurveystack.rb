# This script runs every few hrs (15 mins min) to get suitable surveys from Federated Sample Offerwall to Ketsci stack

require 'httparty'

# Get offerwall surveys from Federated Sample

begin
  sleep(5)
  puts 'CONNECTING FOR OFFERWALL SURVEYS LIST'
  offerwallresponse = HTTParty.get("http://vpc-stg-apiloadbalancer-1968605456.us-east-1.elb.amazonaws.com/Supply/v1/Surveys/AllOfferwall/5411?key=5F7599DD-AB3B-4EFC-9193-A202B9ACEF0E")
    rescue HTTParty::Error => e
    puts 'HttParty::Error '+ e.message
    retry
end while offerwallresponse.code != 200

puts offerwallresponse
totalavailablesurveys = offerwallresponse["ResultCount"] - 1
puts totalavailablesurveys+1

(0..totalavailablesurveys).each do |i|
  if ((offerwallresponse["Surveys"][i]["CountryLanguageID"] == nil ) || (offerwallresponse["Surveys"][i]["CountryLanguageID"] == 72) || (offerwallresponse["Surveys"][i]["CountryLanguageID"] == 72) || (offerwallresponse["Surveys"][i]["CountryLanguageID"] == 11)) && ((offerwallresponse["Surveys"][i]["StudyTypeID"] == nil ) || (offerwallresponse["Surveys"][i]["StudyTypeID"] == 1) || (offerwallresponse["Surveys"][i]["StudyTypeID"] == 8) || (offerwallresponse["Surveys"][i]["StudyTypeID"] == 9) || (offerwallresponse["Surveys"][i]["StudyTypeID"] == 10) || (offerwallresponse["Surveys"][i]["StudyTypeID"] == 11) || (offerwallresponse["Surveys"][i]["StudyTypeID"] == 12) || (offerwallresponse["Surveys"][i]["StudyTypeID"] == 13) || (offerwallresponse["Surveys"][i]["StudyTypeID"] == 14) || (offerwallresponse["Surveys"][i]["StudyTypeID"] == 15) || (offerwallresponse["Surveys"][i]["StudyTypeID"] == 16) || (offerwallresponse["Surveys"][i]["StudyTypeID"] == 21) || (offerwallresponse["Surveys"][i]["StudyTypeID"] == 23)) && ((offerwallresponse["Surveys"][i]["BidIncidence"] == nil ) || (offerwallresponse["Surveys"][i]["BidIncidence"] > 10 )) && ((offerwallresponse["Surveys"][i]["BidLengthOfInterview"] == nil ) || (offerwallresponse["Surveys"][i]["BidLengthOfInterview"] < 31)) then
    #	Survey = Survey.new
    #	Survey.SurveyName = offerwallresponse["Surveys"][i]["SurveyName"]
    #	Survey.SurveyNumber = offerwallresponse["Surveys"][i]["SurveyNumber"]
   
	  SurveyName = offerwallresponse["Surveys"][i]["SurveyName"]
	  SurveyNumber = offerwallresponse["Surveys"][i]["SurveyNumber"]
    puts 'PROCESSING i =', i
	  puts SurveyName, SurveyNumber, offerwallresponse["Surveys"][i]["CountryLanguageID"]
    
    # Get Survey Qualifications Information by SurveyNumber
    
    begin
      sleep(5)
      puts 'CONNECTING FOR QUALIFICATIONS INFORMATION'
      SurveyQualifications = HTTParty.get('http://vpc-stg-apiloadbalancer-1968605456.us-east-1.elb.amazonaws.com/Supply/v1/SurveyQualifications/BySurveyNumberForOfferwall/'+SurveyNumber.to_s+'?key=5F7599DD-AB3B-4EFC-9193-A202B9ACEF0E')
        rescue HTTParty::Error => e
        puts 'HttParty::Error '+ e.message
        retry
    end while SurveyQualifications.code != 200

    if SurveyQualifications["SurveyQualification"]["Questions"]!=nil then
      NumberOfQualificationsQuestions = SurveyQualifications["SurveyQualification"]["Questions"].length-1
      puts NumberOfQualificationsQuestions+1
    
      (0..NumberOfQualificationsQuestions).each do |j|
        # Survey.Questions = SurveyQualifications["SurveyQualification"]["Questions"]
        puts SurveyQualifications["SurveyQualification"]["Questions"][j]["QuestionID"]
        
        case SurveyQualifications["SurveyQualification"]["Questions"][j]["QuestionID"]
          when 42
            puts '42:', SurveyQualifications["SurveyQualification"]["Questions"][j].values_at("PreCodes")
            # Survey.Qualification_Age = SurveyQualifications["SurveyQualification"]["Questions"][j].values_at("PreCodes")
          when 43
            puts '43:', SurveyQualifications["SurveyQualification"]["Questions"][j].values_at("PreCodes")
            # Survey.Qualification_Gender = SurveyQualifications["SurveyQualification"]["Questions"][j].values_at("PreCodes")
          # when 42
          # puts '42'
          # Survey.Qualification_ZIP = SurveyQualifications["SurveyQualification"]["Questions"][j].values_at("PreCodes")
        end
      end
    else
      puts 'SurveyQualifications or Questions is NIL'
      # Survey.Qualification_Age = nil
      # Survey.Qualification_Gender = nil
      # Survey.Qualification_ZIP = nil
    end
    
    # Get Survey Quotas Information by SurveyNumber
    begin
      sleep(5)
      puts 'CONNECTING FOR QUOTA INFORMATION'
      SurveyQuotas = HTTParty.get('http://vpc-stg-apiloadbalancer-1968605456.us-east-1.elb.amazonaws.com/Supply/v1/SurveyQuotas/BySurveyNumber/'+SurveyNumber.to_s+'/5411?key=5F7599DD-AB3B-4EFC-9193-A202B9ACEF0E')
        rescue HTTParty::Error => e
        puts 'HttParty::Error '+ e.message
        retry
    end while SurveyQuotas.code != 200

    # Survey.SurveyStillLive = SurveyQuotas["SurveyStillLive"]
      NumberOfQuotas = SurveyQuotas["SurveyQuotas"].length-1
      puts NumberOfQuotas+1

      (0..NumberOfQuotas).each do |k|
        NumberOfRespondents = SurveyQuotas["SurveyQuotas"][k]["NumberOfRespondents"]
        SurveyQuotaCPI = SurveyQuotas["SurveyQuotas"][k]["QuotaCPI"]
        puts NumberOfRespondents, SurveyQuotaCPI
        puts SurveyQuotas["SurveyQuotas"][k]["Questions"]
        
        if (SurveyQuotas["SurveyQuotas"][k]["Questions"] == nil ) then
          # Survey.Quota_Age = nil
          # Survey.Quota_Gender = nil
          # Survey.Quota_ZIP = nil
        else
          (0..SurveyQuotas["SurveyQuotas"][k]["Questions"].length-1).each do |l|
            case SurveyQuotas["SurveyQuotas"][k]["Questions"][l]["QuestionID"]
              when 42
                puts '42:', SurveyQuotas["SurveyQuotas"][k]["Questions"][l].values_at("PreCodes")
                # Survey.Quota_Age = SurveyQuotas["SurveyQuotas"][k]["Questions"][l].values_at("PreCodes")
              when 43
                puts '43', SurveyQuotas["SurveyQuotas"][k]["Questions"][l].values_at("PreCodes")
                # Survey.Quota_Gender = SurveyQuotas["SurveyQuotas"][k]["Questions"][l].values_at("PreCodes")
              # when 42
              # puts '42'
              # Survey.Quota_ZIP = SurveyQuotas["SurveyQuotas"][k]["Questions"][l].values_at("PreCodes")
            end
          end
        end
      end
    
    # Assign an initial gross rank to the chosen survey
    
    case offerwallresponse["Surveys"][i]["Conversion"]
      when 0..4
        puts "Rank 1"
      when 5..9
        puts "Rank 2"
      when 10..14
        puts "Rank 3"
      when 15..19
        puts "Rank 4"
      when 20..24
        puts "Rank 5"
      when 25..29
        puts "Rank 6"
      when 30..34
        puts "Rank 7"
      when 35..39
        puts "Rank 8"
      when 40..44
        puts "Rank 9"
      when 45..100
        puts "Rank 10"
    end
    
    # Create Supplierlink for the survey
    
    begin
      sleep(5)
      puts 'POSTING TO GET SURVEYLINK'
      SupplierLink = HTTParty.post('http://vpc-stg-apiloadbalancer-1968605456.us-east-1.elb.amazonaws.com/Supply/v1/SupplierLinks/Create/'+SurveyNumber.to_s+'/5411?key=5F7599DD-AB3B-4EFC-9193-A202B9ACEF0E',
        :body => { :SupplierLinkTypeCode => "OWS", :TrackingTypeCode => "S2S" }.to_json,
    :headers => { 'Content-Type' => 'application/json' })
        rescue HTTParty::Error => e
        puts 'HttParty::Error '+ e.message
        retry
    end while SurveyQuotas.code != 200
    puts SupplierLink["SupplierLink"]
    puts SupplierLink["SupplierLink"]["LiveLink"]
    # Survey.SupplierLink=SupplierLink["SupplierLink"]["LiveLink"]    
    
    #	Survey.save - in separate country tables Survey_US, ...
    
  else
  end
end