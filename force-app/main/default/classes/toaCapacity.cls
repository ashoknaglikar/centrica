//Methods Included: get_capacity, get_quota_data, set_quota, set_quota_close_time, get_quota_close_time
// Primary Port Class Name: toa_capacity_interface  
public class toaCapacity {
    public class activity_field_element {
        public String name;
        public String value;
        private String[] name_type_info = new String[]{'name','urn:toa:capacity','string','1','1','false'};
        private String[] value_type_info = new String[]{'value','urn:toa:capacity','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','true','false'};
        private String[] field_order_type_info = new String[]{'name','value'};
    }
    public class capacity_element {
        public String location;
        public Date date_x;
        public String time_slot;
        public String work_skill;
        public Long quota;
        public Long available;
        private String[] location_type_info = new String[]{'location','urn:toa:capacity','string','0','1','false'};
        private String[] date_x_type_info = new String[]{'date','urn:toa:capacity','date','1','1','false'};
        private String[] time_slot_type_info = new String[]{'time_slot','urn:toa:capacity','string','0','1','false'};
        private String[] work_skill_type_info = new String[]{'work_skill','urn:toa:capacity','string','0','1','false'};
        private String[] quota_type_info = new String[]{'quota','urn:toa:capacity','long','1','1','false'};
        private String[] available_type_info = new String[]{'available','urn:toa:capacity','long','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'location','date_x','time_slot','work_skill','quota','available'};
    }
    public class capacity_request_element {
        public toaCapacity.user_element user_x;
        public Date[] date_x;
        public String[] location;
        public Boolean calculate_duration;
        public Boolean calculate_travel_time;
        public Boolean calculate_work_skill;
        public Boolean return_time_slot_info;
        public Boolean determine_location_by_work_zone;
        public Boolean dont_aggregate_results;
        public Integer min_time_to_end_of_time_slot;
        public Integer default_duration;
        public String[] time_slot;
        public String[] work_skill;
        public toaCapacity.activity_field_element[] activity_field;
        private String[] user_x_type_info = new String[]{'user','urn:toa:capacity','user_element','1','1','false'};
        private String[] date_x_type_info = new String[]{'date','urn:toa:capacity','date','1','-1','false'};
        private String[] location_type_info = new String[]{'location','urn:toa:capacity','string','0','-1','false'};
        private String[] calculate_duration_type_info = new String[]{'calculate_duration','urn:toa:capacity','boolean','0','1','false'};
        private String[] calculate_travel_time_type_info = new String[]{'calculate_travel_time','urn:toa:capacity','boolean','0','1','false'};
        private String[] calculate_work_skill_type_info = new String[]{'calculate_work_skill','urn:toa:capacity','boolean','0','1','false'};
        private String[] return_time_slot_info_type_info = new String[]{'return_time_slot_info','urn:toa:capacity','boolean','0','1','false'};
        private String[] determine_location_by_work_zone_type_info = new String[]{'determine_location_by_work_zone','urn:toa:capacity','boolean','0','1','false'};
        private String[] dont_aggregate_results_type_info = new String[]{'dont_aggregate_results','urn:toa:capacity','boolean','0','1','false'};
        private String[] min_time_to_end_of_time_slot_type_info = new String[]{'min_time_to_end_of_time_slot','urn:toa:capacity','int','0','1','false'};
        private String[] default_duration_type_info = new String[]{'default_duration','urn:toa:capacity','int','0','1','false'};
        private String[] time_slot_type_info = new String[]{'time_slot','urn:toa:capacity','string','0','-1','false'};
        private String[] work_skill_type_info = new String[]{'work_skill','urn:toa:capacity','string','0','-1','false'};
        private String[] activity_field_type_info = new String[]{'activity_field','urn:toa:capacity','activity_field_element','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','date_x','location','calculate_duration','calculate_travel_time','calculate_work_skill','return_time_slot_info','determine_location_by_work_zone','dont_aggregate_results','min_time_to_end_of_time_slot','default_duration','time_slot','work_skill','activity_field'};
    }
    public class capacity_response_element {
        public Long activity_duration;
        public Long activity_travel_time;
        public toaCapacity.capacity_element[] capacity;
        public toaCapacity.time_slot_info_element[] time_slot_info;
        private String[] activity_duration_type_info = new String[]{'activity_duration','urn:toa:capacity','long','0','1','false'};
        private String[] activity_travel_time_type_info = new String[]{'activity_travel_time','urn:toa:capacity','long','0','1','false'};
        private String[] capacity_type_info = new String[]{'capacity','urn:toa:capacity','capacity_element','0','-1','false'};
        private String[] time_slot_info_type_info = new String[]{'time_slot_info','urn:toa:capacity','time_slot_info_element','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'activity_duration','activity_travel_time','capacity','time_slot_info'};
    }
    public class get_quota_close_time_request_element {
        public toaCapacity.user_element user_x;
        public String bucket_id;
        public Integer day_offset;
        public String time_slot;
        public String category;
        public String work_zone;
        private String[] user_x_type_info = new String[]{'user','urn:toa:capacity','user_element','1','1','false'};
        private String[] bucket_id_type_info = new String[]{'bucket_id','urn:toa:capacity','string','1','1','false'};
        private String[] day_offset_type_info = new String[]{'day_offset','urn:toa:capacity','unsignedByte','0','1','false'};
        private String[] time_slot_type_info = new String[]{'time_slot','urn:toa:capacity','string','0','1','false'};
        private String[] category_type_info = new String[]{'category','urn:toa:capacity','string','0','1','false'};
        private String[] work_zone_type_info = new String[]{'work_zone','urn:toa:capacity','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','true','false'};
        private String[] field_order_type_info = new String[]{'user_x','bucket_id','day_offset','time_slot','category','work_zone'};
    }
    public class get_quota_close_time_response_element {
        public toaCapacity.quota_close_time_schedule[] close_schedule;
        private String[] close_schedule_type_info = new String[]{'close_schedule','urn:toa:capacity','quota_close_time_schedule','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','true','false'};
        private String[] field_order_type_info = new String[]{'close_schedule'};
    }
    public class get_quota_data_bucket_element {
        public String bucket_id;
        public String name;
        public toaCapacity.get_quota_data_day_element[] day;
        private String[] bucket_id_type_info = new String[]{'bucket_id','urn:toa:capacity','string','0','1','false'};
        private String[] name_type_info = new String[]{'name','urn:toa:capacity','string','0','1','false'};
        private String[] day_type_info = new String[]{'day','urn:toa:capacity','get_quota_data_day_element','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'bucket_id','name','day'};
    }
    public class get_quota_data_category_element {
        public String label;
        public Double quota_percent;
        public Integer min_quota;
        public Integer quota;
        public Integer stop_booking_at;
        public Double weight;
        public Double estimated_quota_percent;
        public Integer status;
        public string close_time;
        public string closed_at;
        public Integer max_available;
        public Integer used;
        public Double used_quota_percent;
        public Integer count;
        public Integer plan;
        public toaCapacity.get_quota_data_work_zone_element[] work_zone;
        private String[] label_type_info = new String[]{'label','urn:toa:capacity','string','1','1','false'};
        private String[] quota_percent_type_info = new String[]{'quota_percent','urn:toa:capacity','float','0','1','false'};
        private String[] min_quota_type_info = new String[]{'min_quota','urn:toa:capacity','int','0','1','false'};
        private String[] quota_type_info = new String[]{'quota','urn:toa:capacity','int','0','1','false'};
        private String[] stop_booking_at_type_info = new String[]{'stop_booking_at','urn:toa:capacity','unsignedShort','0','1','false'};
        private String[] weight_type_info = new String[]{'weight','urn:toa:capacity','float','0','1','false'};
        private String[] estimated_quota_percent_type_info = new String[]{'estimated_quota_percent','urn:toa:capacity','float','0','1','false'};
        private String[] status_type_info = new String[]{'status','urn:toa:capacity','unsignedByte','0','1','false'};
        private String[] close_time_type_info = new String[]{'close_time','urn:toa:capacity','dateTime','0','1','false'};
        private String[] closed_at_type_info = new String[]{'closed_at','urn:toa:capacity','dateTime','0','1','false'};
        private String[] max_available_type_info = new String[]{'max_available','urn:toa:capacity','int','0','1','false'};
        private String[] used_type_info = new String[]{'used','urn:toa:capacity','int','0','1','false'};
        private String[] used_quota_percent_type_info = new String[]{'used_quota_percent','urn:toa:capacity','float','0','1','false'};
        private String[] count_type_info = new String[]{'count','urn:toa:capacity','int','0','1','false'};
        private String[] plan_type_info = new String[]{'plan','urn:toa:capacity','int','0','1','false'};
        private String[] work_zone_type_info = new String[]{'work_zone','urn:toa:capacity','get_quota_data_work_zone_element','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'label','quota_percent','min_quota','quota','stop_booking_at','weight','estimated_quota_percent','status','close_time','closed_at','max_available','used','used_quota_percent','count','plan','work_zone'};
    }
    public class get_quota_data_day_element {
        public Date date_x;
        public Double quota_percent;
        public Integer min_quota;
        public Integer quota;
        public Integer status;
        public DateTime close_time;
        public DateTime closed_at;
        public Integer max_available;
        public Integer other_activities;
        public Integer used;
        public Double used_quota_percent;
        public Integer count;
        public Integer plan;
        public toaCapacity.get_quota_data_time_slot_element[] time_slot;
        public toaCapacity.get_quota_data_day_total_element total;
        private String[] date_x_type_info = new String[]{'date','urn:toa:capacity','date','1','1','false'};
        private String[] quota_percent_type_info = new String[]{'quota_percent','urn:toa:capacity','float','0','1','false'};
        private String[] min_quota_type_info = new String[]{'min_quota','urn:toa:capacity','int','0','1','false'};
        private String[] quota_type_info = new String[]{'quota','urn:toa:capacity','int','0','1','false'};
        private String[] status_type_info = new String[]{'status','urn:toa:capacity','unsignedByte','0','1','false'};
        private String[] close_time_type_info = new String[]{'close_time','urn:toa:capacity','dateTime','0','1','false'};
        private String[] closed_at_type_info = new String[]{'closed_at','urn:toa:capacity','dateTime','0','1','false'};
        private String[] max_available_type_info = new String[]{'max_available','urn:toa:capacity','int','0','1','false'};
        private String[] other_activities_type_info = new String[]{'other_activities','urn:toa:capacity','int','0','1','false'};
        private String[] used_type_info = new String[]{'used','urn:toa:capacity','int','0','1','false'};
        private String[] used_quota_percent_type_info = new String[]{'used_quota_percent','urn:toa:capacity','float','0','1','false'};
        private String[] count_type_info = new String[]{'count','urn:toa:capacity','int','0','1','false'};
        private String[] plan_type_info = new String[]{'plan','urn:toa:capacity','int','0','1','false'};
        private String[] time_slot_type_info = new String[]{'time_slot','urn:toa:capacity','get_quota_data_time_slot_element','0','-1','false'};
        private String[] total_type_info = new String[]{'total','urn:toa:capacity','get_quota_data_day_total_element','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'date_x','quota_percent','min_quota','quota','status','close_time','closed_at','max_available','other_activities','used','used_quota_percent','count','plan','time_slot','total'};
    }
    public class get_quota_data_day_total_element {
        public Integer quota;
        public Integer max_available;
        public Integer other_activities;
        public Integer used;
        public Integer count;
        public Integer plan;
        private String[] quota_type_info = new String[]{'quota','urn:toa:capacity','int','0','1','false'};
        private String[] max_available_type_info = new String[]{'max_available','urn:toa:capacity','int','0','1','false'};
        private String[] other_activities_type_info = new String[]{'other_activities','urn:toa:capacity','int','0','1','false'};
        private String[] used_type_info = new String[]{'used','urn:toa:capacity','int','0','1','false'};
        private String[] count_type_info = new String[]{'count','urn:toa:capacity','int','0','1','false'};
        private String[] plan_type_info = new String[]{'plan','urn:toa:capacity','int','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'quota','max_available','other_activities','used','count','plan'};
    }
    public class get_quota_data_request_element {
        public toaCapacity.user_element user_x;
        public Date[] date_x;
        public String[] resource_id;
        public Boolean aggregate_results;
        public Boolean calculate_totals;
        public String[] time_slot;
        public String[] category;
        public String[] day_quota_field;
        public String[] time_slot_quota_field;
        public String[] category_quota_field;
        public String[] work_zone_quota_field;
        private String[] user_x_type_info = new String[]{'user','urn:toa:capacity','user_element','1','1','false'};
        private String[] date_x_type_info = new String[]{'date','urn:toa:capacity','date','1','-1','false'};
        private String[] resource_id_type_info = new String[]{'resource_id','urn:toa:capacity','string','1','-1','false'};
        private String[] aggregate_results_type_info = new String[]{'aggregate_results','urn:toa:capacity','boolean','0','1','false'};
        private String[] calculate_totals_type_info = new String[]{'calculate_totals','urn:toa:capacity','boolean','0','1','false'};
        private String[] time_slot_type_info = new String[]{'time_slot','urn:toa:capacity','string','0','-1','false'};
        private String[] category_type_info = new String[]{'category','urn:toa:capacity','string','0','-1','false'};
        private String[] day_quota_field_type_info = new String[]{'day_quota_field','urn:toa:capacity','string','0','-1','false'};
        private String[] time_slot_quota_field_type_info = new String[]{'time_slot_quota_field','urn:toa:capacity','string','0','-1','false'};
        private String[] category_quota_field_type_info = new String[]{'category_quota_field','urn:toa:capacity','string','0','-1','false'};
        private String[] work_zone_quota_field_type_info = new String[]{'work_zone_quota_field','urn:toa:capacity','string','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','date_x','resource_id','aggregate_results','calculate_totals','time_slot','category','day_quota_field','time_slot_quota_field','category_quota_field','work_zone_quota_field'};
    }
    public class get_quota_data_response_element {
        public toaCapacity.get_quota_data_bucket_element[] bucket;
        private String[] bucket_type_info = new String[]{'bucket','urn:toa:capacity','get_quota_data_bucket_element','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'bucket'};
    }
    public class get_quota_data_time_slot_element {
        public String label;
        public Double quota_percent;
        public Integer min_quota;
        public Integer quota;
        public Integer stop_booking_at;
        public Integer status;
        public DateTime close_time;
        public DateTime closed_at;
        public Integer max_available;
        public Integer other_activities;
        public Integer used;
        public Double used_quota_percent;
        public Integer count;
        public Integer plan;
        public toaCapacity.get_quota_data_category_element[] category;
        public toaCapacity.get_quota_data_time_slot_total_element total;
        private String[] label_type_info = new String[]{'label','urn:toa:capacity','string','1','1','false'};
        private String[] quota_percent_type_info = new String[]{'quota_percent','urn:toa:capacity','float','0','1','false'};
        private String[] min_quota_type_info = new String[]{'min_quota','urn:toa:capacity','int','0','1','false'};
        private String[] quota_type_info = new String[]{'quota','urn:toa:capacity','int','0','1','false'};
        private String[] stop_booking_at_type_info = new String[]{'stop_booking_at','urn:toa:capacity','unsignedShort','0','1','false'};
        private String[] status_type_info = new String[]{'status','urn:toa:capacity','unsignedByte','0','1','false'};
        private String[] close_time_type_info = new String[]{'close_time','urn:toa:capacity','dateTime','0','1','false'};
        private String[] closed_at_type_info = new String[]{'closed_at','urn:toa:capacity','dateTime','0','1','false'};
        private String[] max_available_type_info = new String[]{'max_available','urn:toa:capacity','int','0','1','false'};
        private String[] other_activities_type_info = new String[]{'other_activities','urn:toa:capacity','int','0','1','false'};
        private String[] used_type_info = new String[]{'used','urn:toa:capacity','int','0','1','false'};
        private String[] used_quota_percent_type_info = new String[]{'used_quota_percent','urn:toa:capacity','float','0','1','false'};
        private String[] count_type_info = new String[]{'count','urn:toa:capacity','int','0','1','false'};
        private String[] plan_type_info = new String[]{'plan','urn:toa:capacity','int','0','1','false'};
        private String[] category_type_info = new String[]{'category','urn:toa:capacity','get_quota_data_category_element','0','-1','false'};
        private String[] total_type_info = new String[]{'total','urn:toa:capacity','get_quota_data_time_slot_total_element','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'label','quota_percent','min_quota','quota','stop_booking_at','status','close_time','closed_at','max_available','other_activities','used','used_quota_percent','count','plan','category','total'};
    }
    public class get_quota_data_time_slot_total_element {
        public Integer quota;
        public Integer max_available;
        public Integer used;
        public Integer count;
        public Integer plan;
        private String[] quota_type_info = new String[]{'quota','urn:toa:capacity','int','0','1','false'};
        private String[] max_available_type_info = new String[]{'max_available','urn:toa:capacity','int','0','1','false'};
        private String[] used_type_info = new String[]{'used','urn:toa:capacity','int','0','1','false'};
        private String[] count_type_info = new String[]{'count','urn:toa:capacity','int','0','1','false'};
        private String[] plan_type_info = new String[]{'plan','urn:toa:capacity','int','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'quota','max_available','used','count','plan'};
    }
    public class get_quota_data_work_zone_element {
        public String label;
        public Integer status;
        public String close_time;
        public String closed_at;
        private String[] label_type_info = new String[]{'label','urn:toa:capacity','string','1','1','false'};
        private String[] status_type_info = new String[]{'status','urn:toa:capacity','unsignedByte','0','1','false'};
        private String[] close_time_type_info = new String[]{'close_time','urn:toa:capacity','dateTime','0','1','false'};
        private String[] closed_at_type_info = new String[]{'closed_at','urn:toa:capacity','dateTime','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'label','status','close_time','closed_at'};
    }
    public class quota_close_time_schedule {
        public String bucket_id;
        public Integer day_offset;
        public String time_slot;
        public String category;
        public String work_zone;
        public Time close_time;
        private String[] bucket_id_type_info = new String[]{'bucket_id','urn:toa:capacity','string','1','1','false'};
        private String[] day_offset_type_info = new String[]{'day_offset','urn:toa:capacity','unsignedByte','0','1','false'};
        private String[] time_slot_type_info = new String[]{'time_slot','urn:toa:capacity','string','0','1','false'};
        private String[] category_type_info = new String[]{'category','urn:toa:capacity','string','0','1','false'};
        private String[] work_zone_type_info = new String[]{'work_zone','urn:toa:capacity','string','0','1','false'};
        private String[] close_time_type_info = new String[]{'close_time','urn:toa:capacity','time','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'bucket_id','day_offset','time_slot','category','work_zone','close_time'};
    }
    public class set_quota_bucket_element {
        public String bucket_id;
        public toaCapacity.set_quota_day_element[] day;
        private String[] bucket_id_type_info = new String[]{'bucket_id','urn:toa:capacity','string','1','1','false'};
        private String[] day_type_info = new String[]{'day','urn:toa:capacity','set_quota_day_element','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'bucket_id','day'};
    }
    public class set_quota_category_element {
        public String label;
        public Double quota_percent;
        public Integer min_quota;
        public Integer quota;
        public Integer stop_booking_at;
        public Integer status;
        public toaCapacity.set_quota_work_zone_element[] work_zone;
        private String[] label_type_info = new String[]{'label','urn:toa:capacity','string','1','1','false'};
        private String[] quota_percent_type_info = new String[]{'quota_percent','urn:toa:capacity','float','0','1','false'};
        private String[] min_quota_type_info = new String[]{'min_quota','urn:toa:capacity','int','0','1','false'};
        private String[] quota_type_info = new String[]{'quota','urn:toa:capacity','int','0','1','false'};
        private String[] stop_booking_at_type_info = new String[]{'stop_booking_at','urn:toa:capacity','unsignedShort','0','1','false'};
        private String[] status_type_info = new String[]{'status','urn:toa:capacity','unsignedByte','0','1','false'};
        private String[] work_zone_type_info = new String[]{'work_zone','urn:toa:capacity','set_quota_work_zone_element','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'label','quota_percent','min_quota','quota','stop_booking_at','status','work_zone'};
    }
    public class set_quota_close_time_request_element {
        public toaCapacity.user_element user_x;
        public toaCapacity.quota_close_time_schedule[] close_schedule;
        private String[] user_x_type_info = new String[]{'user','urn:toa:capacity','user_element','1','1','false'};
        private String[] close_schedule_type_info = new String[]{'close_schedule','urn:toa:capacity','quota_close_time_schedule','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','close_schedule'};
    }
    public class set_quota_close_time_response_element {
        public toaCapacity.set_quota_close_time_result[] result;
        private String[] result_type_info = new String[]{'result','urn:toa:capacity','set_quota_close_time_result','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class set_quota_close_time_result {
        public String bucket_id;
        public Integer day_offset;
        public String time_slot;
        public String category;
        public String work_zone;
        public Integer result_code;
        public String error_msg;
        private String[] bucket_id_type_info = new String[]{'bucket_id','urn:toa:capacity','string','1','1','false'};
        private String[] day_offset_type_info = new String[]{'day_offset','urn:toa:capacity','unsignedByte','0','1','false'};
        private String[] time_slot_type_info = new String[]{'time_slot','urn:toa:capacity','string','0','1','false'};
        private String[] category_type_info = new String[]{'category','urn:toa:capacity','string','0','1','false'};
        private String[] work_zone_type_info = new String[]{'work_zone','urn:toa:capacity','string','0','1','false'};
        private String[] result_code_type_info = new String[]{'result_code','urn:toa:capacity','int','1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toa:capacity','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'bucket_id','day_offset','time_slot','category','work_zone','result_code','error_msg'};
    }
    public class set_quota_day_element {
        public Date date_x;
        public Double quota_percent;
        public Integer min_quota;
        public Integer quota;
        public Integer status;
        public toaCapacity.set_quota_time_slot_element[] time_slot;
        private String[] date_x_type_info = new String[]{'date','urn:toa:capacity','date','1','1','false'};
        private String[] quota_percent_type_info = new String[]{'quota_percent','urn:toa:capacity','float','0','1','false'};
        private String[] min_quota_type_info = new String[]{'min_quota','urn:toa:capacity','int','0','1','false'};
        private String[] quota_type_info = new String[]{'quota','urn:toa:capacity','int','0','1','false'};
        private String[] status_type_info = new String[]{'status','urn:toa:capacity','unsignedByte','0','1','false'};
        private String[] time_slot_type_info = new String[]{'time_slot','urn:toa:capacity','set_quota_time_slot_element','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'date_x','quota_percent','min_quota','quota','status','time_slot'};
    }
    public class set_quota_request_element {
        public toaCapacity.user_element user_x;
        public toaCapacity.set_quota_bucket_element[] bucket;
        private String[] user_x_type_info = new String[]{'user','urn:toa:capacity','user_element','1','1','false'};
        private String[] bucket_type_info = new String[]{'bucket','urn:toa:capacity','set_quota_bucket_element','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','bucket'};
    }
    public class set_quota_response_element {
        public toaCapacity.set_quota_result_element[] result;
        private String[] result_type_info = new String[]{'result','urn:toa:capacity','set_quota_result_element','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class set_quota_result_element {
        public String bucket_id;
        public String date_x;
        public String time_slot;
        public String category;
        public Integer result_code;
        public String error_msg;
        private String[] bucket_id_type_info = new String[]{'bucket_id','urn:toa:capacity','string','0','1','false'};
        private String[] date_x_type_info = new String[]{'date','urn:toa:capacity','string','0','1','false'};
        private String[] time_slot_type_info = new String[]{'time_slot','urn:toa:capacity','string','0','1','false'};
        private String[] category_type_info = new String[]{'category','urn:toa:capacity','string','0','1','false'};
        private String[] result_code_type_info = new String[]{'result_code','urn:toa:capacity','int','1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toa:capacity','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'bucket_id','date_x','time_slot','category','result_code','error_msg'};
    }
    public class set_quota_time_slot_element {
        public String label;
        public Double quota_percent;
        public Integer min_quota;
        public Integer quota;
        public Integer stop_booking_at;
        public Integer status;
        public toaCapacity.set_quota_category_element[] category;
        private String[] label_type_info = new String[]{'label','urn:toa:capacity','string','1','1','false'};
        private String[] quota_percent_type_info = new String[]{'quota_percent','urn:toa:capacity','float','0','1','false'};
        private String[] min_quota_type_info = new String[]{'min_quota','urn:toa:capacity','int','0','1','false'};
        private String[] quota_type_info = new String[]{'quota','urn:toa:capacity','int','0','1','false'};
        private String[] stop_booking_at_type_info = new String[]{'stop_booking_at','urn:toa:capacity','unsignedShort','0','1','false'};
        private String[] status_type_info = new String[]{'status','urn:toa:capacity','unsignedByte','0','1','false'};
        private String[] category_type_info = new String[]{'category','urn:toa:capacity','set_quota_category_element','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'label','quota_percent','min_quota','quota','stop_booking_at','status','category'};
    }
    public class set_quota_work_zone_element {
        public String label;
        public Integer status;
        private String[] label_type_info = new String[]{'label','urn:toa:capacity','string','1','1','false'};
        private String[] status_type_info = new String[]{'status','urn:toa:capacity','unsignedByte','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'label','status'};
    }
    public class time_slot_info_element {
        public String name;
        public String label;
        public string time_from;
        public string time_to;
        private String[] name_type_info = new String[]{'name','urn:toa:capacity','string','1','1','false'};
        private String[] label_type_info = new String[]{'label','urn:toa:capacity','string','1','1','false'};
        private String[] time_from_type_info = new String[]{'time_from','urn:toa:capacity','time','0','1','false'};
        private String[] time_to_type_info = new String[]{'time_to','urn:toa:capacity','time','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','false','false'};
        private String[] field_order_type_info = new String[]{'name','label','time_from','time_to'};
    }
    public class toa_capacity_interface {
        public String endpoint_x = system.label.TOA_End_Point;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:toa:capacity','toaCapacity'};

        public toaCapacity.capacity_response_element get_capacity(toaCapacity.user_element user_x,Date[] date_x,String[] location,Boolean calculate_duration,Boolean calculate_travel_time,Boolean calculate_work_skill,Boolean return_time_slot_info,Boolean determine_location_by_work_zone,Boolean dont_aggregate_results,Integer min_time_to_end_of_time_slot,Integer default_duration,String[] time_slot,String[] work_skill,toaCapacity.activity_field_element[] activity_field) {
            toaCapacity.capacity_request_element request_x = new toaCapacity.capacity_request_element();
            toaCapacity.capacity_response_element response_x;
            request_x.user_x = user_x;
            request_x.date_x = date_x;
            request_x.location = location;
            request_x.calculate_duration = calculate_duration;
            request_x.calculate_travel_time = calculate_travel_time;
            request_x.calculate_work_skill = calculate_work_skill;
            request_x.return_time_slot_info = return_time_slot_info;
            request_x.determine_location_by_work_zone = determine_location_by_work_zone;
            request_x.dont_aggregate_results = dont_aggregate_results;
            request_x.min_time_to_end_of_time_slot = min_time_to_end_of_time_slot;
            request_x.default_duration = default_duration;
            request_x.time_slot = time_slot;
            request_x.work_skill = work_skill;
            request_x.activity_field = activity_field;
            Map<String, toaCapacity.capacity_response_element> response_map_x = new Map<String, toaCapacity.capacity_response_element>();
            response_map_x.put('response_x', response_x);
            if(!Test.isRunningTest()){
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'toa_capacity_interface/get_capacity',
                'urn:toa:capacity',
                'get_capacity',
                'urn:toa:capacity',
                'get_capacity_response',
                'toaCapacity.capacity_response_element'}
            );
            system.debug('----->'+response_x);
            response_x = response_map_x.get('response_x');
            system.debug(':*'+response_map_x);
            }
            else{  // fake response 
                toaCapacity.capacity_element capacity_ele1 = new toaCapacity.capacity_element();
                capacity_ele1.available=1324;
                capacity_ele1.date_x=date.today().addYears(100);
                capacity_ele1.location='a0A20000002RrXhEAK';
                capacity_ele1.quota=1600;
                capacity_ele1.time_slot='EV';
                capacity_ele1.work_skill='standard_cc';
               toaCapacity.capacity_element[] capacity_ele = new toaCapacity.capacity_element[]{capacity_ele1};
               toaCapacity.time_slot_info_element time_slot1 = new toaCapacity.time_slot_info_element();
                time_slot1.label='AM';
                time_slot1.name='1 - AM';
                time_slot1.time_from='09:00:00';
                time_slot1.time_to='13:00:00';
               toaCapacity.time_slot_info_element[] time_slot_info_ele = new toaCapacity.time_slot_info_element[]{time_slot1};
                toaCapacity.capacity_response_element Resp = new toaCapacity.capacity_response_element();  
                Resp.activity_duration=null;
                Resp.activity_travel_time=6;
                Resp.capacity=capacity_ele;
                Resp.time_slot_info=time_slot_info_ele;
                
                response_x = Resp;
            }
            //
            return response_x;
        }

        public toaCapacity.quota_close_time_schedule[] get_quota_close_time(toaCapacity.user_element user_x,String bucket_id,Integer day_offset,String time_slot,String category,String work_zone) {
            toaCapacity.get_quota_close_time_request_element request_x = new toaCapacity.get_quota_close_time_request_element();
            toaCapacity.get_quota_close_time_response_element response_x;
            request_x.user_x = user_x;
            request_x.bucket_id = bucket_id;
            request_x.day_offset = day_offset;
            request_x.time_slot = time_slot;
            request_x.category = category;
            request_x.work_zone = work_zone;
            Map<String, toaCapacity.get_quota_close_time_response_element> response_map_x = new Map<String, toaCapacity.get_quota_close_time_response_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'toa_capacity_interface/get_quota_close_time',
                'urn:toa:capacity',
                'get_quota_close_time',
                'urn:toa:capacity',
                'get_quota_close_time_response',
                'toaCapacity.get_quota_close_time_response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.close_schedule;
        }

        public toaCapacity.get_quota_data_bucket_element[] get_quota_data(toaCapacity.user_element user_x,Date[] date_x,String[] resource_id,Boolean aggregate_results,Boolean calculate_totals,String[] time_slot,String[] category,String[] day_quota_field,String[] time_slot_quota_field,String[] category_quota_field,String[] work_zone_quota_field) {
            toaCapacity.get_quota_data_request_element request_x = new toaCapacity.get_quota_data_request_element();
            toaCapacity.get_quota_data_response_element response_x;
            request_x.user_x = user_x;
            request_x.date_x = date_x;
            request_x.resource_id = resource_id;
            request_x.aggregate_results = aggregate_results;
            request_x.calculate_totals = calculate_totals;
            request_x.time_slot = time_slot;
            request_x.category = category;
            request_x.day_quota_field = day_quota_field;
            request_x.time_slot_quota_field = time_slot_quota_field;
            request_x.category_quota_field = category_quota_field;
            request_x.work_zone_quota_field = work_zone_quota_field;
            Map<String, toaCapacity.get_quota_data_response_element> response_map_x = new Map<String, toaCapacity.get_quota_data_response_element>();
            response_map_x.put('response_x', response_x);
            if(!Test.isRunningTest()){
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'toa_capacity_interface/get_quota_data',
                'urn:toa:capacity',
                'get_quota_data',
                'urn:toa:capacity',
                'get_quota_data_response',
                'toaCapacity.get_quota_data_response_element'}
            );
            system.debug('====>'+request_x);
            response_x = response_map_x.get('response_x');
            }
            else{//Fake Response for Test Coverage
                 toaCapacity.get_quota_data_category_element Category1 = new toaCapacity.get_quota_data_category_element();
                 
                 category1.count=null;
                 category1.label='standard_cc';
                 category1.max_available=1800; 
                 category1.quota=1600;
                 category1.used=null;
                 toaCapacity.get_quota_data_time_slot_total_element tot = new get_quota_data_time_slot_total_element();
                 tot.count=null;tot.max_available=1800;tot.plan=null;tot.quota=1600;tot.used=null;
                 toaCapacity.get_quota_data_category_element[] Cate = new toaCapacity.get_quota_data_category_element[]{category1};
                 toaCapacity.get_quota_data_time_slot_element TimeEle = new toaCapacity.get_quota_data_time_slot_element();
                 timeEle.label='AM';
                 timeEle.max_available=null; 
                 timeEle.other_activities=300;
                 timeEle.quota=null;
                 timeEle.category = cate; 
                 timeEle.total = tot;
                 toaCapacity.get_quota_data_time_slot_element[] TimeElements = new toaCapacity.get_quota_data_time_slot_element[]{TimeEle};
                 toaCapacity.get_quota_data_day_element DayEle = new toaCapacity.get_quota_data_day_element();
                 DayEle.date_x = date.today();
                 Dayele.max_available=null; 
                 DayEle.time_slot = TimeElements;
                 toaCapacity.get_quota_data_day_element[] DayElements = new toaCapacity.get_quota_data_day_element[]{DayEle};
                 toaCapacity.get_quota_data_bucket_element Resp1 = new toaCapacity.get_quota_data_bucket_element();
                 Resp1.bucket_id='a0A20000002RrXhEAK';
                 Resp1.name='Greenwich & Sutton';
                 Resp1.day = DayElements;
                 toaCapacity.get_quota_data_bucket_element[] Resp = new  toaCapacity.get_quota_data_bucket_element[]{Resp1};
                 toaCapacity.get_quota_data_response_element QResp = new toaCapacity.get_quota_data_response_element();
                 QResp.bucket = Resp; 
                 
                 response_x = QResp;
                }
            return response_x.bucket;
        }

        public toaCapacity.set_quota_result_element[] set_quota(toaCapacity.user_element user_x,toaCapacity.set_quota_bucket_element[] bucket) {
            toaCapacity.set_quota_request_element request_x = new toaCapacity.set_quota_request_element();
            toaCapacity.set_quota_response_element response_x;
            request_x.user_x = user_x;
            request_x.bucket = bucket;
            Map<String, toaCapacity.set_quota_response_element> response_map_x = new Map<String, toaCapacity.set_quota_response_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'toa_capacity_interface/set_quota',
                'urn:toa:capacity',
                'set_quota',
                'urn:toa:capacity',
                'set_quota_response',
                'toaCapacity.set_quota_response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }

        public toaCapacity.set_quota_close_time_result[] set_quota_close_time(toaCapacity.user_element user_x,toaCapacity.quota_close_time_schedule[] close_schedule) {
            toaCapacity.set_quota_close_time_request_element request_x = new toaCapacity.set_quota_close_time_request_element();
            toaCapacity.set_quota_close_time_response_element response_x;
            request_x.user_x = user_x;
            request_x.close_schedule = close_schedule;
            Map<String, toaCapacity.set_quota_close_time_response_element> response_map_x = new Map<String, toaCapacity.set_quota_close_time_response_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'toa_capacity_interface/set_quota_close_time',
                'urn:toa:capacity',
                'set_quota_close_time',
                'urn:toa:capacity',
                'set_quota_close_time_response',
                'toaCapacity.set_quota_close_time_response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
    }
    public class user_element {
        public String now;
        public String login;
        public String company;
        public String auth_string;
        private String[] now_type_info = new String[]{'now','urn:toa:capacity','string','1','1','false'};
        private String[] login_type_info = new String[]{'login','urn:toa:capacity','string','1','1','false'};
        private String[] company_type_info = new String[]{'company','urn:toa:capacity','string','1','1','false'};
        private String[] auth_string_type_info = new String[]{'auth_string','urn:toa:capacity','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toa:capacity','true','false'};
        private String[] field_order_type_info = new String[]{'now','login','company','auth_string'};
    }
}