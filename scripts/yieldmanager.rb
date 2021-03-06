# This script updates survey ranks to the new rankings to manage best yield


begin
# set timer to run every 20 mins

  starttime = Time.now
  print 'YieldManager: Time at start', starttime
  puts
    
  Survey.all.each do |toberankedsurvey|

    # Safety 1-95
    if (0 < toberankedsurvey.SurveyGrossRank) && (toberankedsurvey.SurveyGrossRank <= 95) then

      # Only low CPI and TCR > 0.066 surveys in this group. Surveys arrive in TCR order. If they do not perform move them to Horrible.

      if (toberankedsurvey.TotalRemaining == 0) || (Time.now - toberankedsurvey.created_at > 86400*50) then

        if toberankedsurvey.Conversion == 0 then
          toberankedsurvey.SurveyGrossRank = 800
          toberankedsurvey.label = 'D: Rem = 0'

        else

          toberankedsurvey.SurveyGrossRank = 701+(100-toberankedsurvey.Conversion)
          print "Assigned 0 Remaining / Old to Dead: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
          puts
          toberankedsurvey.label = 'D: Rem = 0'
        end

      else            

        @toberankedsurveyNumberofAttemptsSinceLastComplete = toberankedsurvey.SurveyExactRank - toberankedsurvey.NumberofAttemptsAtLastComplete

        if (@toberankedsurveyNumberofAttemptsSinceLastComplete > 15) then  # worst than 6.6% conversion rate i.e. 15 more after they were moved out of New

          if toberankedsurvey.Conversion == 0 then # to squeeze 101 conversion values in 100 levels
            toberankedsurvey.SurveyGrossRank = 700
            toberankedsurvey.label = 'H: CPI<1.5 and TCR<0.066'
  
          else

            toberankedsurvey.SurveyGrossRank = 601+(100-toberankedsurvey.Conversion)
            print "Assigned Safety survey to Horrible: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
            puts
            toberankedsurvey.TCR = 1.0 / @toberankedsurveyNumberofAttemptsSinceLastComplete
            toberankedsurvey.label = 'H: CPI<1.5 and TCR<0.066'
          end

        else
          
          if (toberankedsurvey.TCR == 1) then
            toberankedsurvey.SurveyGrossRank = 1
            print "Reposition Safety: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
            puts
            toberankedsurvey.label = 'S: Repositioned'
          else
            
            toberankedsurvey.SurveyGrossRank = 100 - (toberankedsurvey.TCR * 100)
            print "Reposition Safety: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
            puts
            toberankedsurvey.label = 'S: Repositioned'
            
          end

        end

      end # TotalRemaining


    else # not in 1-95 rank range
    end # not in 1-95 rank range

    # Showcase 96-100
    if (95 < toberankedsurvey.SurveyGrossRank) && (toberankedsurvey.SurveyGrossRank <= 100) then
      # do nothing. surveys are put here manually to give them quick exposure to traffic when network is ACTIVE or in SAFETY mode
    else
    end  # not in 96-100 range

    # Fast Converters 101-200        
    if (100 < toberankedsurvey.SurveyGrossRank) && (toberankedsurvey.SurveyGrossRank <= 200) then

      # Only high CPI and TCR > 0.066 (fast converters) in this group. Surveys arrive in TCR order. If they do not perform move them to Bad.          

      if (toberankedsurvey.TotalRemaining == 0) || (Time.now - toberankedsurvey.created_at > 86400*50) then

        if toberankedsurvey.Conversion == 0 then
          toberankedsurvey.SurveyGrossRank = 800
          toberankedsurvey.label = 'D: Rem = 0'

        else

          toberankedsurvey.SurveyGrossRank = 701+(100-toberankedsurvey.Conversion)
          print "Assigned 0 Remaining / Old to Dead: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
          puts
          toberankedsurvey.label = 'D: Rem = 0'
        end

      else

        @toberankedsurveyNumberofAttemptsSinceLastComplete = toberankedsurvey.SurveyExactRank - toberankedsurvey.NumberofAttemptsAtLastComplete

        if (@toberankedsurveyNumberofAttemptsSinceLastComplete > 15) then

          if toberankedsurvey.Conversion == 0 then # to squeeze 101 conversion values in 100 levels
            toberankedsurvey.SurveyGrossRank = 600
            toberankedsurvey.label = 'B: TCR<0.066'
  
          else

            toberankedsurvey.SurveyGrossRank = 501+(100-toberankedsurvey.Conversion)
            print "Assigned Fast survey to Bad: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
            puts
            toberankedsurvey.TCR = 1.0 / @toberankedsurveyNumberofAttemptsSinceLastComplete
            toberankedsurvey.label = 'B: TCR<0.066'
          end

        else

          toberankedsurvey.SurveyGrossRank = 201 - (toberankedsurvey.TCR * 100)
          print "Reposition Fast: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
          puts
          toberankedsurvey.label = 'F: Repositioned'

        end

      end # TotalRemaining          


    else # not in 101-200 rank range
    end # not in 101-200 rank range

    # Good (New+Conv>0) 201-300
    if (200 < toberankedsurvey.SurveyGrossRank) && (toberankedsurvey.SurveyGrossRank <= 300) then

      # This is the place for new surveys to be tested with first 10 hits. They move to Fast or Try more if they do not complete in 10. If they changed to Conv=0 then move them to Conv=0

      if (toberankedsurvey.TotalRemaining == 0) || (Time.now - toberankedsurvey.created_at > 86400*50) then

        if toberankedsurvey.Conversion == 0 then
          toberankedsurvey.SurveyGrossRank = 800
          toberankedsurvey.label = 'D: Rem = 0'

        else

          toberankedsurvey.SurveyGrossRank = 701+(100-toberankedsurvey.Conversion)
          print "Assigned 0 Remaining / Old to Dead: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
          puts
          toberankedsurvey.label = 'D: Rem = 0'
        end

      else         

        if (toberankedsurvey.CompletedBy.length > 0) && (toberankedsurvey.TCR >= 0.10) then # (1 in 10 hits)

          if (toberankedsurvey.CPI > 1.49) then

            toberankedsurvey.SurveyGrossRank = 201 - (toberankedsurvey.TCR * 100)
            print "Assigned From Conv>0 to Fast: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
            toberankedsurvey.label = 'F: From Conv>0'

          else

              toberankedsurvey.SurveyGrossRank = 101 - (toberankedsurvey.TCR * 100)
              print "Assigned From Conv>0 to Safety: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
              toberankedsurvey.label = 'S: From Conv>0'
  
          end 

        else # Completes > 0 or TCR >= 0.1
        end # Completes > 0 or TCR >= 0.1

        if (toberankedsurvey.CompletedBy.length == 0) then

          if toberankedsurvey.CPI > 0 then
            @GCR = toberankedsurvey.GEPC / toberankedsurvey.CPI
          else
            @GCR = toberankedsurvey.GEPC
          end

          if (toberankedsurvey.Conversion == 0) then
      
            if (@GCR >= 1) then
              toberankedsurvey.SurveyGrossRank = 401
              print "Assigned a Conv>0 to Conv=0: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
              puts 
              toberankedsurvey.label = 'Conv=0 from Conv>0'
 
            else
  
              toberankedsurvey.SurveyGrossRank = 500-(100*@GCR)
              print "Assigned a Conv>0 to Conv=0: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
              puts    
              toberankedsurvey.label = 'Conv=0 from Conv>0'
            end
      

          else # Conversion>0

              if (toberankedsurvey.SurveyExactRank > 10) then
          
                if toberankedsurvey.Conversion == 0 then
                  toberankedsurvey.SurveyGrossRank = 400
                  print "Assigned Conv>0 to TM: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
                  puts 
                  toberankedsurvey.label = 'TM: From Conv>0'

                else

                  toberankedsurvey.SurveyGrossRank = 301+(100-toberankedsurvey.Conversion)
                  print "Assigned Conv>0 to TM:", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
                  puts
                  toberankedsurvey.label = 'TM: From Conv>0'
                end
          
  
              else # less than 10 hits
      
                # do nothing until it gets 10 hits, reposition within 201-300
                   
                if toberankedsurvey.Conversion == 0 then
                  toberankedsurvey.SurveyGrossRank = 300
                  print "Repositioned Conv>0: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
                  puts 
                  toberankedsurvey.label = 'Conv>0: Repositioned'

                else

                  toberankedsurvey.SurveyGrossRank = 201+(100-toberankedsurvey.Conversion)
                  print "Repositioned Conv>0: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
                  puts
                  toberankedsurvey.label = 'Conv>0: Repositioned'
                end

              end # more than 10 hits on a GCR>=0.01

          end # Conversion=0
  
        else # completes = 0
        end # completes = 0
        
      end  # TotalRemaining = 0

    else # not in 201-300 rank range
    end # not in 201-300 rank range

    # Try More 301-400
    if (300 < toberankedsurvey.SurveyGrossRank) && (toberankedsurvey.SurveyGrossRank <= 400) then

      # These surveys are here to get another 5 attempts (10 to 15). If they convert move them to Fast else take them to Horrible        

      if (toberankedsurvey.TotalRemaining == 0) || (Time.now - toberankedsurvey.created_at > 86400*50) then

        if toberankedsurvey.Conversion == 0 then
          toberankedsurvey.SurveyGrossRank = 800
          toberankedsurvey.label = 'D: Rem = 0'

        else

          toberankedsurvey.SurveyGrossRank = 701+(100-toberankedsurvey.Conversion)
          print "Assigned 0 Remaining / Old to Dead: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
          puts
          toberankedsurvey.label = 'D: Rem = 0'
        end

      else                            

        if (toberankedsurvey.CompletedBy.length > 0) && (toberankedsurvey.TCR >= 0.066) then

          if (toberankedsurvey.CPI > 1.49) then

            toberankedsurvey.SurveyGrossRank = 201 - (toberankedsurvey.TCR * 100)
            print "Assigned Try more survey to Fast: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
            puts
            toberankedsurvey.label = 'F: From TM'

          else   

              toberankedsurvey.SurveyGrossRank = 101 - (toberankedsurvey.TCR * 100)
              print "Assigned Try more survey to Safety: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
              puts
              toberankedsurvey.label = 'S: From TM'
  
          end 

        else # Completes > 0 or TCR >= 0.066
        end # Completes > 0 or TCR >= 0.066

        if (toberankedsurvey.CompletedBy.length == 0) then


          if toberankedsurvey.CPI > 0 then
            @GCR = toberankedsurvey.GEPC / toberankedsurvey.CPI
          else
            @GCR = toberankedsurvey.GEPC
          end
              
          if toberankedsurvey.SurveyExactRank <= 15 then # No. of hits

            # do nothing - let it get 15 hits. Reposition for updated Conversion
 
            if (toberankedsurvey.Conversion > 0) then

                toberankedsurvey.SurveyGrossRank = 301+(100-toberankedsurvey.Conversion)
                print "Repositioned TM: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
                puts
                toberankedsurvey.label = 'TM: Repositioned'
    
            else # Conversion changed to = 0
                  
              if (@GCR >= 1) then
                toberankedsurvey.SurveyGrossRank = 401
                print "Assigned a TM to Conv=0: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
                puts 
                toberankedsurvey.label = 'Conv=0: changed in TM'
 
              else
  
                toberankedsurvey.SurveyGrossRank = 500-(100*@GCR)
                print "Assigned a TM to Conv=0: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
                puts    
                toberankedsurvey.label = 'Conv=0: changed in TM'
        
              end
        
           end # Conversion values 
    
          else # No. of hits > 15

            if toberankedsurvey.Conversion == 0 then # to squeeze 101 conversion values in 100 levels
              p "Found a toberankedsurvey with Conversion = 0"
              toberankedsurvey.SurveyGrossRank = 700
              toberankedsurvey.label = 'H: Hits>15, TCR=0'
    
            else

              toberankedsurvey.SurveyGrossRank = 601+(100-toberankedsurvey.Conversion)
              print "Assigned a Try More to Horrible: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
              puts   
              toberankedsurvey.label = 'H: Hits>15, TCR=0'
            end

          end # No. of hits

        else # number of completes = 0
        end # number of completes = 0

      end  # TotalRemaining 
    
    else # not in rank 401-500 range
    end # not in rank 301-400 range

    # Poor (New+Conv=0) 401-500
    if (400 < toberankedsurvey.SurveyGrossRank) && (toberankedsurvey.SurveyGrossRank <= 500) then

      # This is the place for new Conv=0 (Poor) surveys. If they make TCR>0.066 then move to Fast or Safety. Move to Bad if TCR<0.066 but more than 0. They move to Horrible if they do not complete in 10. If they turn GCR>=0.01 then move them to GCR>=0.01. 


      if (toberankedsurvey.TotalRemaining == 0) || (Time.now - toberankedsurvey.created_at > 86400*50) then

        if toberankedsurvey.Conversion == 0 then
          toberankedsurvey.SurveyGrossRank = 800
          toberankedsurvey.label = 'D: Rem = 0'

        else

          toberankedsurvey.SurveyGrossRank = 701+(100-toberankedsurvey.Conversion)
          print "Assigned 0 Remaining / Old to Dead: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
          puts
          toberankedsurvey.label = 'D: Rem = 0'
        end

      else              

        if (toberankedsurvey.CompletedBy.length > 0) && (toberankedsurvey.TCR >= 0.066) then # (1 in 10 hits)

          if (toberankedsurvey.CPI > 1.49) then

            toberankedsurvey.SurveyGrossRank = 201 - (toberankedsurvey.TCR * 100)
            print "Assigned Poor survey to Fast: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
            toberankedsurvey.label = 'F: TCR>0.066 from Poor'

          else   

              toberankedsurvey.SurveyGrossRank = 101 - (toberankedsurvey.TCR * 100)
              print "Assigned Poor survey to Safety: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
              toberankedsurvey.label = 'S: TCR>0.066 from Poor'

          end 

        else # Completes > 0 or TCR >= 0.066
        end # Completes > 0 or TCR >= 0.066

        if (toberankedsurvey.CompletedBy.length > 0) && (toberankedsurvey.TCR > 0) && (toberankedsurvey.TCR < 0.066)

          if toberankedsurvey.Conversion == 0 then # to squeeze 101 conversion values in 100 levels
            toberankedsurvey.SurveyGrossRank = 600
            toberankedsurvey.label = 'B: From Poor'

          else

            toberankedsurvey.SurveyGrossRank = 501+(100-toberankedsurvey.Conversion)
            print "Assigned New/GCR<0.01 survey rank to OldTimers+Bad: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
            puts    
            toberankedsurvey.label = 'B: From Poor'
          end

        else
        end  # Completes > 0 or 0 < TCR >= 0.066

        if (toberankedsurvey.CompletedBy.length == 0) then

          if toberankedsurvey.CPI > 0 then
            @GCR = toberankedsurvey.GEPC / toberankedsurvey.CPI
          else
            @GCR = toberankedsurvey.GEPC
          end

          if (toberankedsurvey.Conversion > 0) then

            toberankedsurvey.SurveyGrossRank = 201+(100-toberankedsurvey.Conversion)
            print "Conv>0: Conv changed,  From P: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
            puts    
            toberankedsurvey.label = 'Conv>0: Conv changed, From P'

          else # (Conversion=0)

              if (toberankedsurvey.SurveyExactRank > 10) then

                toberankedsurvey.SurveyGrossRank = 700
                print "Assigned New/GCR<0.01 survey rank to Horrible: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
                puts
                toberankedsurvey.label = 'H: From Poor'

              else
    
                # wait until there are 10 attempts, Reposition within 401-500 block                
          
                if (@GCR >= 1) then
                  toberankedsurvey.SurveyGrossRank = 401
                  print "Repositioned Poor: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
                  puts 
                  toberankedsurvey.label = 'Poor: Repositioned'
 
                else
  
                  toberankedsurvey.SurveyGrossRank = 500-(100*@GCR)
                  print "Poor: Repositioned: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
                  puts    
                  toberankedsurvey.label = 'Poor: Repositioned'
        
                end
       
              end # more than 10 hits

          end # Conv >0

        else # completes = 0
        end # completes = 0

      end  # TotalRemaining


    else # not in 301-400 rank range
    end # not in 301-400 rank range

    # Bad 501-600
    if (500 < toberankedsurvey.SurveyGrossRank) && (toberankedsurvey.SurveyGrossRank <= 600) then

      # These are surveys that were good earlier but have fizzled to 0 < TCR < 0.066. The bad converters with TCR < 0.066 are also here. Ordered by Conversion. If their TCR becomes > 0.066 move them to Fast.

      if (toberankedsurvey.TotalRemaining == 0) || (Time.now - toberankedsurvey.created_at > 86400*50) then

          if toberankedsurvey.Conversion == 0 then
            toberankedsurvey.SurveyGrossRank = 800
            toberankedsurvey.label = 'D: Rem = 0'

          else

            toberankedsurvey.SurveyGrossRank = 701+(100-toberankedsurvey.Conversion)
            print "Assigned 0 Remaining / Old to Dead: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
            puts
            toberankedsurvey.label = 'D: Rem = 0'
          end

      else

        if (toberankedsurvey.CompletedBy.length > 0) && (toberankedsurvey.TCR >= 0.066) then

          toberankedsurvey.SurveyGrossRank = 201 - (toberankedsurvey.TCR * 100)
          print "Assigned OldTimer survey to Fast: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
          toberankedsurvey.label = 'F: TCR>0.066 in B'
        else
        end     

        if (toberankedsurvey.CompletedBy.length == 0) then
          # Reposition according to latest Conversion

          if toberankedsurvey.Conversion == 0 then # to squeeze 101 conversion values in 100 levels
            toberankedsurvey.SurveyGrossRank = 600
            print "B: Repositioned: ", toberankedsurvey.SurveyGrossRank
            puts
            toberankedsurvey.label = 'B: Repositioned'
  
          else

            toberankedsurvey.SurveyGrossRank = 501+(100-toberankedsurvey.Conversion)
            print "B: Repositioned: ", toberankedsurvey.SurveyGrossRank
            puts
            toberankedsurvey.label = 'B: Repositioned'
          end

        else
        end

      end  # TotalRemaining

    else # not in rank 501-600 range
    end # not in rank 501-600 range

    # Horrible 601-700
    if (600 < toberankedsurvey.SurveyGrossRank) && (toberankedsurvey.SurveyGrossRank <= 700) then

       # These are surveys which have seen moree than 15 attempts without a complete, if GCR>=0.01 or 10 attempts if GCR<0.01. Ordered by Conversion. If they do start converting then move them to appropriate buckets. Low CPI surveys that fizzle also land up here.

      if (toberankedsurvey.TotalRemaining == 0) || (Time.now - toberankedsurvey.created_at > 86400*50) then

        if toberankedsurvey.Conversion == 0 then
          toberankedsurvey.SurveyGrossRank = 800
          toberankedsurvey.label = 'D: Rem = 0'

        else

          toberankedsurvey.SurveyGrossRank = 701+(100-toberankedsurvey.Conversion)
          print "Assigned 0-Remaining / Old to Dead: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
          puts
          toberankedsurvey.label = 'D: Rem = 0'
        end

      else          

        if (toberankedsurvey.CompletedBy.length > 0) && (toberankedsurvey.TCR >= 0.066) then

          if toberankedsurvey.CPI > 1.49 then

            toberankedsurvey.SurveyGrossRank = 201 - (toberankedsurvey.TCR * 100).to_i
            print "Assigned Horrible survey to Fast: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
            toberankedsurvey.label = 'F: TCR>0.066 from H'
  
          else
  
            toberankedsurvey.SurveyGrossRank = 101 - (toberankedsurvey.TCR * 100).to_i
            print "Assigned Horrible survey to Fast: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
            toberankedsurvey.label = 'S: TCR>0.066 from H'
          end
  
        else
        end

        if ((toberankedsurvey.CompletedBy.length > 0) && (toberankedsurvey.TCR > 0) && (toberankedsurvey.TCR < 0.066)) then

          toberankedsurvey.SurveyGrossRank = 600 - (toberankedsurvey.TCR * 100)
          print "Assigned Horrible survey to Bad: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
          toberankedsurvey.label = 'B: TCR>0.066 from H'
        else
        end

        if (toberankedsurvey.CompletedBy.length == 0) then
          # Reposition according to latest Conversion

          if toberankedsurvey.CPI > 0 then
            @GCR = toberankedsurvey.GEPC / toberankedsurvey.CPI
          else
            @GCR = toberankedsurvey.GEPC
          end
         
          @toberankedsurveyNumberofAttemptsSinceLastComplete = toberankedsurvey.SurveyExactRank - toberankedsurvey.NumberofAttemptsAtLastComplete

          if (toberankedsurvey.Conversion > 0) && (@toberankedsurveyNumberofAttemptsSinceLastComplete < 15) then
    
            toberankedsurvey.SurveyGrossRank = 301+(100-toberankedsurvey.Conversion)
            print "TM: From H: ", toberankedsurvey.SurveyGrossRank
            puts
            toberankedsurvey.label = 'TM: From H'
   
          else     

            if toberankedsurvey.Conversion == 0 then # to squeeze 101 conversion values in 100 levels
              toberankedsurvey.SurveyGrossRank = 700
              toberankedsurvey.label = 'H: Repositioned'
  
            else

              toberankedsurvey.SurveyGrossRank = 601+(100-toberankedsurvey.Conversion)
              print "Updated existing Horrible survey rank to: ", toberankedsurvey.SurveyGrossRank
              puts
              toberankedsurvey.label = 'H: Repositioned'
            end

          end # Conv, ALC conditions

        else
        end # no of completes = 0

      end  # TotalRemaining      

    else # not in rank 601-700 range
    end # not in rank 601-700 range

    # Dead 701-800
    if (700 < toberankedsurvey.SurveyGrossRank) && (toberankedsurvey.SurveyGrossRank <= 800) then

      if (toberankedsurvey.TotalRemaining == 0) || (Time.now - toberankedsurvey.created_at > 86400*50) then

        # do nothing about it - stays dead

      else
    
          if (toberankedsurvey.CompletedBy.length > 0) && (toberankedsurvey.TCR >= 0.066) then

            if toberankedsurvey.CPI > 1.49 then

              toberankedsurvey.SurveyGrossRank = 201 - (toberankedsurvey.TCR * 100)
              print "Assigned Dead survey to Fast: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
              toberankedsurvey.label = 'F: TCR>0.066 from D'
  
            else
  
              toberankedsurvey.SurveyGrossRank = 101 - (toberankedsurvey.TCR * 100)
              print "Assigned Dead survey to Fast: ", toberankedsurvey.SurveyGrossRank, ' Survey number = ', toberankedsurvey.SurveyNumber
              toberankedsurvey.label = 'S: TCR>0.066 from D'
            end
  
          else
      
          end # Complete>0 & TCR >= 0.066

          if ((toberankedsurvey.CompletedBy.length > 0) && (toberankedsurvey.TCR > 0) && (toberankedsurvey.TCR < 0.066)) then
      
            if toberankedsurvey.Conversion == 0 then # to squeeze 101 conversion values in 100 levels
              toberankedsurvey.SurveyGrossRank = 600
              print "Dead survey to Bad: ", toberankedsurvey.SurveyGrossRank
              puts
              toberankedsurvey.label = 'B: From Dead'
      
            else
      
              toberankedsurvey.SurveyGrossRank = 501+(100-toberankedsurvey.Conversion)
              print "Dead survey to Bad: ", toberankedsurvey.SurveyGrossRank
              puts
              toberankedsurvey.label = 'B: From Dead'
        
            end
    
          else
 
          end # Complete>0 & 0 < TCR >= 0.066

          if (toberankedsurvey.CompletedBy.length == 0) then
            # Reposition according to latest Conversion

            if toberankedsurvey.CPI > 0 then
              @GCR = toberankedsurvey.GEPC / toberankedsurvey.CPI
            else
              @GCR = toberankedsurvey.GEPC
            end
         
            @toberankedsurveyNumberofAttemptsSinceLastComplete = toberankedsurvey.SurveyExactRank - toberankedsurvey.NumberofAttemptsAtLastComplete
        
        
            if (toberankedsurvey.Conversion > 0) && (@toberankedsurveyNumberofAttemptsSinceLastComplete < 15) then
    
              toberankedsurvey.SurveyGrossRank = 301+(100-toberankedsurvey.Conversion)
              print "TM: From D: ", toberankedsurvey.SurveyGrossRank
              puts
              toberankedsurvey.label = 'TM: From D'

            else     

              if toberankedsurvey.Conversion == 0 then # to squeeze 101 conversion values in 100 levels
                toberankedsurvey.SurveyGrossRank = 800
                toberankedsurvey.label = 'D: Repositioned'
  
              else

                toberankedsurvey.SurveyGrossRank = 701+(100-toberankedsurvey.Conversion)
                print "Updated existing Horrible survey rank to: ", toberankedsurvey.SurveyGrossRank
                puts
                toberankedsurvey.label = 'D: Repositioned'
          
              end

            end # Conv, ALC conditions

          else
          end # no of completes = 0

      end

    else
    end # not in Dead range 701-800

     # Ignore 801-900
    if (800 < toberankedsurvey.SurveyGrossRank) && (toberankedsurvey.SurveyGrossRank <= 900) then
      # do nothing. surveys are put here manually to hide them from ranking
    else
    end  # not in 801-900 range
    
    
    toberankedsurvey.save!

  end # for all toberankedsurvey 
  
  timenow = Time.now
  
  print 'YieldManager: Time at end', timenow
  puts
  if (timenow - starttime) > 1200 then 
    print 'time elapsed since start =', (timenow - starttime), '- going to repeat immediately'
    puts
    timetorepeat = true
  else
    print 'time elapsed since start =', (timenow - starttime), '- going to sleep for 10 minutes'
    puts
    sleep (10.minutes)
    timetorepeat = true
  end

end while timetorepeat

