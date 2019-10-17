public class availabilityWrapper {
    //Week1
        public list<weekTemplateWrapper> weekTemplateMondayList { get; set; }
        public list<weekTemplateWrapper> weekTemplateTuesdayList { get; set; }
        public list<weekTemplateWrapper> weekTemplateWednesdayList { get; set; }
        public list<weekTemplateWrapper> weekTemplateThursdayList { get; set; }
        public list<weekTemplateWrapper> weekTemplateFridayList { get; set; }
        public list<weekTemplateWrapper> weekTemplateSaturdayList { get; set; }
        public list<weekTemplateWrapper> weekTemplateSundayList { get; set; }
        //Week 2
        public list<weekTemplateWrapper> week2TemplateMondayList { get; set; }
        public list<weekTemplateWrapper> week2TemplateTuesdayList { get; set; }
        public list<weekTemplateWrapper> week2TemplateWednesdayList { get; set; }
        public list<weekTemplateWrapper> week2TemplateThursdayList { get; set; }
        public list<weekTemplateWrapper> week2TemplateFridayList { get; set; }
        public list<weekTemplateWrapper> week2TemplateSaturdayList { get; set; }
        public list<weekTemplateWrapper> week2TemplateSundayList { get; set; }
        //Week 3
        public list<weekTemplateWrapper> week3TemplateMondayList { get; set; }
        public list<weekTemplateWrapper> week3TemplateTuesdayList { get; set; }
        public list<weekTemplateWrapper> week3TemplateWednesdayList { get; set; }
        public list<weekTemplateWrapper> week3TemplateThursdayList { get; set; }
        public list<weekTemplateWrapper> week3TemplateFridayList { get; set; }
        public list<weekTemplateWrapper> week3TemplateSaturdayList { get; set; }
        public list<weekTemplateWrapper> week3TemplateSundayList { get; set; }
        //Week 4
        public list<weekTemplateWrapper> week4TemplateMondayList { get; set; }
        public list<weekTemplateWrapper> week4TemplateTuesdayList { get; set; }
        public list<weekTemplateWrapper> week4TemplateWednesdayList { get; set; }
        public list<weekTemplateWrapper> week4TemplateThursdayList { get; set; }
        public list<weekTemplateWrapper> week4TemplateFridayList { get; set; }
        public list<weekTemplateWrapper> week4TemplateSaturdayList { get; set; }
        public list<weekTemplateWrapper> week4TemplateSundayList { get; set; }
        
        
public class weekTemplateWrapper{
        public time startTime { get; set; }
        public time endTime { get; set; }
        public String type { get; set; }
        public Integer appointments { get; set; }
        public boolean active{ get; set; }
        
        public weekTemplateWrapper()
        {
            active =true;
        }
    }
    
}