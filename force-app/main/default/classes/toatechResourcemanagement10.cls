public class toatechResourcemanagement10 {
   /* public class SetResourcesSkillsElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public toatechResourcemanagement10.SkillList skills;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] skills_type_info = new String[]{'skills','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','skills'};
    }
    public class GetUserResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.PropertiesElement properties;
        public toatechResourcemanagement10.ResourceIdListElement resources;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] properties_type_info = new String[]{'properties','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] resources_type_info = new String[]{'resources','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','properties','resources'};
    }
    public class UserListItemElement {
        public toatechResourcemanagement10.PropertiesElement properties;
        private String[] properties_type_info = new String[]{'properties','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'properties'};
    }
    public class ZoneElement {
        public toatechResourcemanagement10.TextPropertiesElement properties;
        private String[] properties_type_info = new String[]{'properties','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'properties'};
    }
    public class ResourceListElement {
        public toatechResourcemanagement10.ResourceListItemElement[] resource;
        private String[] resource_type_info = new String[]{'resource','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'resource'};
    }
    public class GetLocationsResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.LocationList locations;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] locations_type_info = new String[]{'locations','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','locations'};
    }
    public class LocationResultElement {
        public Integer result_code;
        public String result_message;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] result_message_type_info = new String[]{'result_message','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','result_message'};
    }
    public class SetResourcesLocationsElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public toatechResourcemanagement10.ResourceLocationList resource_locations;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] resource_locations_type_info = new String[]{'resource_locations','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','resource_locations'};
    }
    public class GetUserElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public String login;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] login_type_info = new String[]{'login','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','login'};
    }
    public class GetResourceElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public String id;
        public String date_x;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] id_type_info = new String[]{'id','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] date_x_type_info = new String[]{'date','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','id','date_x'};
    }
    public class GetResourcesZonesElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public toatechResourcemanagement10.GetResourcesParamsList resources;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] resources_type_info = new String[]{'resources','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','resources'};
    }
    public class GetResourceResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.PropertiesElement properties;
        public toatechResourcemanagement10.UsersLoginList users;
        public toatechResourcemanagement10.WorkSkillList workskills;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] properties_type_info = new String[]{'properties','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] users_type_info = new String[]{'users','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] workskills_type_info = new String[]{'workskills','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','properties','users','workskills'};
    }
    public class PropertyElement {
        public String name;
        public String value;
        public String mime_type;
        public String file_data;
        private String[] name_type_info = new String[]{'name','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] value_type_info = new String[]{'value','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] mime_type_type_info = new String[]{'mime_type','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] file_data_type_info = new String[]{'file_data','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'name','value','mime_type','file_data'};
    }
    public class SetResourcesSkillsResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.SkillResultList skill_results;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] skill_results_type_info = new String[]{'skill_results','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','skill_results'};
    }
    public class GetResourcesLocationsResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.ResourceLocationList resource_locations;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] resource_locations_type_info = new String[]{'resource_locations','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','resource_locations'};
    }
    public class ResourceLocationList {
        public toatechResourcemanagement10.ResourceLocationElement[] resource_location;
        private String[] resource_location_type_info = new String[]{'resource_location','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'resource_location'};
    }
    public class SetResourcesLocationsResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.SetResourcesLocationsResultList resource_location_results;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] resource_location_results_type_info = new String[]{'resource_location_results','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','resource_location_results'};
    }
    */
    public class GetResourcesCalendarsElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public toatechResourcemanagement10.GetResourcesParamsList resources;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] resources_type_info = new String[]{'resources','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','resources'};
    }
    public class CalendarElement {
        public toatechResourcemanagement10.TextPropertiesElement properties;
        private String[] properties_type_info = new String[]{'properties','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'properties'};
    }
    /*
    public class PropertiesElement {
        public toatechResourcemanagement10.PropertyElement[] property;
        private String[] property_type_info = new String[]{'property','urn:toatech:ResourceManagement:1.0',null,'1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'property'};
    }
    public class ZoneResultElement {
        public Integer zone_result_code;
        public String zone_error_msg;
        public String userdata;
        private String[] zone_result_code_type_info = new String[]{'zone_result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] zone_error_msg_type_info = new String[]{'zone_error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] userdata_type_info = new String[]{'userdata','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'zone_result_code','zone_error_msg','userdata'};
    }
    public class UpdateUserElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public String login;
        public toatechResourcemanagement10.PropertiesElement properties;
        public toatechResourcemanagement10.ResourceIdListElement resources;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] login_type_info = new String[]{'login','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] properties_type_info = new String[]{'properties','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] resources_type_info = new String[]{'resources','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','login','properties','resources'};
    }
    public class GetUsersListResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.UserListElement users;
        public Integer users_count;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] users_type_info = new String[]{'users','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] users_count_type_info = new String[]{'users_count','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','users','users_count'};
    }
    */
    public class GetResourcesParamsElement {
        public String resource_id;
        public String date_x;
        public String include_children;
        public String include_inactive;
        public Integer duration;
        private String[] resource_id_type_info = new String[]{'resource_id','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] date_x_type_info = new String[]{'date','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] include_children_type_info = new String[]{'include_children','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] include_inactive_type_info = new String[]{'include_inactive','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] duration_type_info = new String[]{'duration','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'resource_id','date_x','include_children','include_inactive','duration'};
    }
    /*
    public class InsertResourceElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public String id;
        public toatechResourcemanagement10.PropertiesElement properties;
        public toatechResourcemanagement10.UsersLoginList users;
        public toatechResourcemanagement10.WorkSkillList workskills;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] id_type_info = new String[]{'id','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] properties_type_info = new String[]{'properties','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] users_type_info = new String[]{'users','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] workskills_type_info = new String[]{'workskills','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','id','properties','users','workskills'};
    }
    public class WorkSkillElement {
        public String label;
        public Integer ratio;
        private String[] label_type_info = new String[]{'label','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] ratio_type_info = new String[]{'ratio','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'label','ratio'};
    }
    public class SetLocationResultList {
        public toatechResourcemanagement10.LocationResultElement[] location_result;
        private String[] location_result_type_info = new String[]{'location_result','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'location_result'};
    }
    public class UserListElement {
        public toatechResourcemanagement10.UserListItemElement[] user_x;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x'};
    }
    public class GetResourcesZonesResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.ZoneList zones;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] zones_type_info = new String[]{'zones','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','zones'};
    }
    public class UsersLoginList {
        public String[] login;
        private String[] login_type_info = new String[]{'login','urn:toatech:ResourceManagement:1.0',null,'1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'login'};
    }
    public class GetResourcesLocationsElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public toatechResourcemanagement10.LocationResourceParamsList resources;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] resources_type_info = new String[]{'resources','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','resources'};
    }
    public class SkillElement {
        public toatechResourcemanagement10.TextPropertiesElement properties;
        private String[] properties_type_info = new String[]{'properties','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'properties'};
    }
    public class LocationResourceParams {
        public String resource_id;
        public String include_children;
        private String[] resource_id_type_info = new String[]{'resource_id','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] include_children_type_info = new String[]{'include_children','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'resource_id','include_children'};
    }
    public class SetResourcesZonesResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.ZoneResultList zone_results;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] zone_results_type_info = new String[]{'zone_results','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','zone_results'};
    }
    public class InsertUserElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public String login;
        public toatechResourcemanagement10.PropertiesElement properties;
        public toatechResourcemanagement10.ResourceIdListElement resources;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] login_type_info = new String[]{'login','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] properties_type_info = new String[]{'properties','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] resources_type_info = new String[]{'resources','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','login','properties','resources'};
    }
    public class SetResourcesCalendarsResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.CalendarResultList calendar_results;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] calendar_results_type_info = new String[]{'calendar_results','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','calendar_results'};
    }
    public class SkillResultElement {
        public Integer skill_result_code;
        public String skill_error_msg;
        public String userdata;
        private String[] skill_result_code_type_info = new String[]{'skill_result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] skill_error_msg_type_info = new String[]{'skill_error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] userdata_type_info = new String[]{'userdata','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'skill_result_code','skill_error_msg','userdata'};
    }
    public class SetLocationsElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public toatechResourcemanagement10.LocationList locations;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] locations_type_info = new String[]{'locations','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','locations'};
    }
    public class SetLocationsResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.SetLocationResultList location_results;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] location_results_type_info = new String[]{'location_results','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','location_results'};
    }
    public class SetResourcesZonesElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public toatechResourcemanagement10.ZoneList zones;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] zones_type_info = new String[]{'zones','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','zones'};
    }
    public class ResourceLocationElement {
        public String resource_id;
        public String location_label;
        public String type_x;
        public toatechResourcemanagement10.WeekdaysList weekdays;
        private String[] resource_id_type_info = new String[]{'resource_id','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] location_label_type_info = new String[]{'location_label','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] type_x_type_info = new String[]{'type','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] weekdays_type_info = new String[]{'weekdays','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'resource_id','location_label','type_x','weekdays'};
    }
    public class SkillResultList {
        public toatechResourcemanagement10.SkillResultElement[] skill_result;
        private String[] skill_result_type_info = new String[]{'skill_result','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'skill_result'};
    }
    public class ResourceListItemElement {
        public toatechResourcemanagement10.PropertiesElement properties;
        public toatechResourcemanagement10.WorkSkillList workskills;
        private String[] properties_type_info = new String[]{'properties','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] workskills_type_info = new String[]{'workskills','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'properties','workskills'};
    }
    public class ZoneResultList {
        public toatechResourcemanagement10.ZoneResultElement[] zone_result;
        private String[] zone_result_type_info = new String[]{'zone_result','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'zone_result'};
    }
    public class CalendarResultList {
        public toatechResourcemanagement10.CalendarResultElement[] calendar_result;
        private String[] calendar_result_type_info = new String[]{'calendar_result','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'calendar_result'};
    }
    public class UpdateResourceElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public String id;
        public toatechResourcemanagement10.PropertiesElement properties;
        public toatechResourcemanagement10.UsersLoginList users;
        public toatechResourcemanagement10.WorkSkillList workskills;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] id_type_info = new String[]{'id','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] properties_type_info = new String[]{'properties','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] users_type_info = new String[]{'users','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] workskills_type_info = new String[]{'workskills','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','id','properties','users','workskills'};
    }
    */
    public class GetResourcesCalendarsResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.CalendarList calendars;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] calendars_type_info = new String[]{'calendars','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','calendars'};
    }
    /*
    public class GetResourcesSkillsElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public String expand_complex_skills;
        public toatechResourcemanagement10.GetResourcesParamsList resources;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] expand_complex_skills_type_info = new String[]{'expand_complex_skills','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] resources_type_info = new String[]{'resources','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','expand_complex_skills','resources'};
    }
    public class LocationResourceParamsList {
        public toatechResourcemanagement10.LocationResourceParams[] resource;
        private String[] resource_type_info = new String[]{'resource','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'resource'};
    }
    */
    public class TextPropertyElement {
        public String name;
        public String value;
        private String[] name_type_info = new String[]{'name','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] value_type_info = new String[]{'value','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'name','value'};
    }
    /*
    public class LocationList {
        public toatechResourcemanagement10.LocationElement[] location;
        private String[] location_type_info = new String[]{'location','urn:toatech:ResourceManagement:1.0',null,'1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'location'};
    }
    */
    public class CalendarList {
        public toatechResourcemanagement10.CalendarElement[] calendar;
        private String[] calendar_type_info = new String[]{'calendar','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'calendar'};
    }
    public class AuthNodeElement {
        public String now;
        public String login;
        public String company;
        public String auth_string;
        private String[] now_type_info = new String[]{'now','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] login_type_info = new String[]{'login','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] company_type_info = new String[]{'company','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] auth_string_type_info = new String[]{'auth_string','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'now','login','company','auth_string'};
    }
    /*
    public class LocationLabelList {
        public String[] location_label;
        private String[] location_label_type_info = new String[]{'location_label','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'location_label'};
    }
    public class GetResourcesListResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.ResourceListElement resources;
        public Integer resources_count;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] resources_type_info = new String[]{'resources','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] resources_count_type_info = new String[]{'resources_count','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','resources','resources_count'};
    }
    public class DeleteUserElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public String login;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] login_type_info = new String[]{'login','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','login'};
    }
    public class CalendarResultElement {
        public Integer calendar_result_code;
        public String calendar_error_msg;
        public String userdata;
        private String[] calendar_result_code_type_info = new String[]{'calendar_result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] calendar_error_msg_type_info = new String[]{'calendar_error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] userdata_type_info = new String[]{'userdata','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'calendar_result_code','calendar_error_msg','userdata'};
    }
    public class GetResourcesSkillsResponseElement {
        public Integer result_code;
        public String error_msg;
        public toatechResourcemanagement10.SkillList skills;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] skills_type_info = new String[]{'skills','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg','skills'};
    }
    public class GetLocationsElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public toatechResourcemanagement10.LocationResourceParamsList resources;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] resources_type_info = new String[]{'resources','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','resources'};
    }
    */
    public class GetResourcesParamsList {
        public toatechResourcemanagement10.GetResourcesParamsElement[] resource;
        private String[] resource_type_info = new String[]{'resource','urn:toatech:ResourceManagement:1.0',null,'1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'resource'};
    }
    /*
    public class ResourceIdListElement {
        public String[] id;
        private String[] id_type_info = new String[]{'id','urn:toatech:ResourceManagement:1.0',null,'1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'id'};
    }
    public class WorkSkillList {
        public toatechResourcemanagement10.WorkSkillElement[] workskill;
        public String[] workskill_group;
        private String[] workskill_type_info = new String[]{'workskill','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] workskill_group_type_info = new String[]{'workskill_group','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'workskill','workskill_group'};
    }
    public class RequiredPropertiesElement {
        public String[] label;
        private String[] label_type_info = new String[]{'label','urn:toatech:ResourceManagement:1.0',null,'1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'label'};
    }
    public class SetUserResponseElement {
        public Integer result_code;
        public String error_msg;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg'};
    }
    public class ZoneList {
        public toatechResourcemanagement10.ZoneElement[] zone;
        private String[] zone_type_info = new String[]{'zone','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'zone'};
    }
    public class SetResourcesLocationsResultList {
        public toatechResourcemanagement10.LocationResultElement[] resource_location_result;
        private String[] resource_location_result_type_info = new String[]{'resource_location_result','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'resource_location_result'};
    }
    public class SetResourceResponseElement {
        public Integer result_code;
        public String error_msg;
        private String[] result_code_type_info = new String[]{'result_code','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] error_msg_type_info = new String[]{'error_msg','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'result_code','error_msg'};
    }
    public class SkillList {
        public toatechResourcemanagement10.SkillElement[] skill;
        private String[] skill_type_info = new String[]{'skill','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'skill'};
    }
    public class GetResourcesListElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public String root_resource_id;
        public String include_children;
        public Integer select_from;
        public Integer select_count;
        public String date_x;
        public toatechResourcemanagement10.RequiredPropertiesElement required_properties;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] root_resource_id_type_info = new String[]{'root_resource_id','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] include_children_type_info = new String[]{'include_children','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] select_from_type_info = new String[]{'select_from','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] select_count_type_info = new String[]{'select_count','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] date_x_type_info = new String[]{'date','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] required_properties_type_info = new String[]{'required_properties','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','root_resource_id','include_children','select_from','select_count','date_x','required_properties'};
    }
    */
    public class TextPropertiesElement {
        public toatechResourcemanagement10.TextPropertyElement[] property;
        private String[] property_type_info = new String[]{'property','urn:toatech:ResourceManagement:1.0',null,'1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'property'};
    }
    /*
    public class LocationElement {
        public toatechResourcemanagement10.TextPropertiesElement properties;
        private String[] properties_type_info = new String[]{'properties','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'properties'};
    }
    public class SetResourcesCalendarsElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public toatechResourcemanagement10.CalendarList calendars;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] calendars_type_info = new String[]{'calendars','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','calendars'};
    }
    public class GetUsersListElement {
        public toatechResourcemanagement10.AuthNodeElement user_x;
        public String root_resource_id;
        public Integer select_from;
        public Integer select_count;
        public toatechResourcemanagement10.RequiredPropertiesElement required_properties;
        private String[] user_x_type_info = new String[]{'user','urn:toatech:ResourceManagement:1.0',null,'1','1','false'};
        private String[] root_resource_id_type_info = new String[]{'root_resource_id','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] select_from_type_info = new String[]{'select_from','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] select_count_type_info = new String[]{'select_count','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] required_properties_type_info = new String[]{'required_properties','urn:toatech:ResourceManagement:1.0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'user_x','root_resource_id','select_from','select_count','required_properties'};
    }
    public class WeekdaysList {
        public String[] wd;
        private String[] wd_type_info = new String[]{'wd','urn:toatech:ResourceManagement:1.0',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:toatech:ResourceManagement:1.0','false','false'};
        private String[] field_order_type_info = new String[]{'wd'};
    }
    */
    public class ResourceManagementPort {
        public String endpoint_x = 'https://api.etadirect.com/soap/resource-management/v3/';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:toatech:ResourceManagement:1.0', 'toatechResourcemanagement10'};
       /* public toatechResourcemanagement10.SetResourcesLocationsResponseElement set_resources_locations(toatechResourcemanagement10.AuthNodeElement user_x,toatechResourcemanagement10.ResourceLocationList resource_locations) {
            toatechResourcemanagement10.SetResourcesLocationsElement request_x = new toatechResourcemanagement10.SetResourcesLocationsElement();
            request_x.user_x = user_x;
            request_x.resource_locations = resource_locations;
            toatechResourcemanagement10.SetResourcesLocationsResponseElement response_x;
            Map<String, toatechResourcemanagement10.SetResourcesLocationsResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.SetResourcesLocationsResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/set_resources_locations',
              'urn:toatech:ResourceManagement:1.0',
              'set_resources_locations',
              'urn:toatech:ResourceManagement:1.0',
              'set_resources_locations_response',
              'toatechResourcemanagement10.SetResourcesLocationsResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.SetResourcesZonesResponseElement set_resources_zones(toatechResourcemanagement10.AuthNodeElement user_x,toatechResourcemanagement10.ZoneList zones) {
            toatechResourcemanagement10.SetResourcesZonesElement request_x = new toatechResourcemanagement10.SetResourcesZonesElement();
            request_x.user_x = user_x;
            request_x.zones = zones;
            toatechResourcemanagement10.SetResourcesZonesResponseElement response_x;
            Map<String, toatechResourcemanagement10.SetResourcesZonesResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.SetResourcesZonesResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/set_resources_zones',
              'urn:toatech:ResourceManagement:1.0',
              'set_resources_zones',
              'urn:toatech:ResourceManagement:1.0',
              'set_resources_zones_response',
              'toatechResourcemanagement10.SetResourcesZonesResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.SetResourcesCalendarsResponseElement set_resources_calendars(toatechResourcemanagement10.AuthNodeElement user_x,toatechResourcemanagement10.CalendarList calendars) {
            toatechResourcemanagement10.SetResourcesCalendarsElement request_x = new toatechResourcemanagement10.SetResourcesCalendarsElement();
            request_x.user_x = user_x;
            request_x.calendars = calendars;
            toatechResourcemanagement10.SetResourcesCalendarsResponseElement response_x;
            Map<String, toatechResourcemanagement10.SetResourcesCalendarsResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.SetResourcesCalendarsResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/set_resources_calendars',
              'urn:toatech:ResourceManagement:1.0',
              'set_resources_calendars',
              'urn:toatech:ResourceManagement:1.0',
              'set_resources_calendars_response',
              'toatechResourcemanagement10.SetResourcesCalendarsResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.SetUserResponseElement update_user(toatechResourcemanagement10.AuthNodeElement user_x,String login,toatechResourcemanagement10.PropertiesElement properties,toatechResourcemanagement10.ResourceIdListElement resources) {
            toatechResourcemanagement10.UpdateUserElement request_x = new toatechResourcemanagement10.UpdateUserElement();
            request_x.user_x = user_x;
            request_x.login = login;
            request_x.properties = properties;
            request_x.resources = resources;
            toatechResourcemanagement10.SetUserResponseElement response_x;
            Map<String, toatechResourcemanagement10.SetUserResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.SetUserResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/update_user',
              'urn:toatech:ResourceManagement:1.0',
              'update_user',
              'urn:toatech:ResourceManagement:1.0',
              'update_user_response',
              'toatechResourcemanagement10.SetUserResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.SetUserResponseElement delete_user(toatechResourcemanagement10.AuthNodeElement user_x,String login) {
            toatechResourcemanagement10.DeleteUserElement request_x = new toatechResourcemanagement10.DeleteUserElement();
            request_x.user_x = user_x;
            request_x.login = login;
            toatechResourcemanagement10.SetUserResponseElement response_x;
            Map<String, toatechResourcemanagement10.SetUserResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.SetUserResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/delete_user',
              'urn:toatech:ResourceManagement:1.0',
              'delete_user',
              'urn:toatech:ResourceManagement:1.0',
              'delete_user_response',
              'toatechResourcemanagement10.SetUserResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.SetResourceResponseElement update_resource(toatechResourcemanagement10.AuthNodeElement user_x,String id,toatechResourcemanagement10.PropertiesElement properties,toatechResourcemanagement10.UsersLoginList users,toatechResourcemanagement10.WorkSkillList workskills) {
            toatechResourcemanagement10.UpdateResourceElement request_x = new toatechResourcemanagement10.UpdateResourceElement();
            request_x.user_x = user_x;
            request_x.id = id;
            request_x.properties = properties;
            request_x.users = users;
            request_x.workskills = workskills;
            toatechResourcemanagement10.SetResourceResponseElement response_x;
            Map<String, toatechResourcemanagement10.SetResourceResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.SetResourceResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/update_resource',
              'urn:toatech:ResourceManagement:1.0',
              'update_resource',
              'urn:toatech:ResourceManagement:1.0',
              'update_resource_response',
              'toatechResourcemanagement10.SetResourceResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.GetUsersListResponseElement get_users_list(toatechResourcemanagement10.AuthNodeElement user_x,String root_resource_id,Integer select_from,Integer select_count,toatechResourcemanagement10.RequiredPropertiesElement required_properties) {
            toatechResourcemanagement10.GetUsersListElement request_x = new toatechResourcemanagement10.GetUsersListElement();
            request_x.user_x = user_x;
            request_x.root_resource_id = root_resource_id;
            request_x.select_from = select_from;
            request_x.select_count = select_count;
            request_x.required_properties = required_properties;
            toatechResourcemanagement10.GetUsersListResponseElement response_x;
            Map<String, toatechResourcemanagement10.GetUsersListResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.GetUsersListResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/get_users_list',
              'urn:toatech:ResourceManagement:1.0',
              'get_users_list',
              'urn:toatech:ResourceManagement:1.0',
              'get_users_list_response',
              'toatechResourcemanagement10.GetUsersListResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.SetResourceResponseElement insert_resource(toatechResourcemanagement10.AuthNodeElement user_x,String id,toatechResourcemanagement10.PropertiesElement properties,toatechResourcemanagement10.UsersLoginList users,toatechResourcemanagement10.WorkSkillList workskills) {
            toatechResourcemanagement10.InsertResourceElement request_x = new toatechResourcemanagement10.InsertResourceElement();
            request_x.user_x = user_x;
            request_x.id = id;
            request_x.properties = properties;
            request_x.users = users;
            request_x.workskills = workskills;
            toatechResourcemanagement10.SetResourceResponseElement response_x;
            Map<String, toatechResourcemanagement10.SetResourceResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.SetResourceResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/insert_resource',
              'urn:toatech:ResourceManagement:1.0',
              'insert_resource',
              'urn:toatech:ResourceManagement:1.0',
              'insert_resource_response',
              'toatechResourcemanagement10.SetResourceResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.GetResourceResponseElement get_resource(toatechResourcemanagement10.AuthNodeElement user_x,String id,String date_x) {
            toatechResourcemanagement10.GetResourceElement request_x = new toatechResourcemanagement10.GetResourceElement();
            request_x.user_x = user_x;
            request_x.id = id;
            request_x.date_x = date_x;
            toatechResourcemanagement10.GetResourceResponseElement response_x;
            Map<String, toatechResourcemanagement10.GetResourceResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.GetResourceResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/get_resource',
              'urn:toatech:ResourceManagement:1.0',
              'get_resource',
              'urn:toatech:ResourceManagement:1.0',
              'get_resource_response',
              'toatechResourcemanagement10.GetResourceResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.GetResourcesLocationsResponseElement get_resources_locations(toatechResourcemanagement10.AuthNodeElement user_x,toatechResourcemanagement10.LocationResourceParamsList resources) {
            toatechResourcemanagement10.GetResourcesLocationsElement request_x = new toatechResourcemanagement10.GetResourcesLocationsElement();
            request_x.user_x = user_x;
            request_x.resources = resources;
            toatechResourcemanagement10.GetResourcesLocationsResponseElement response_x;
            Map<String, toatechResourcemanagement10.GetResourcesLocationsResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.GetResourcesLocationsResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/get_resources_locations',
              'urn:toatech:ResourceManagement:1.0',
              'get_resources_locations',
              'urn:toatech:ResourceManagement:1.0',
              'get_resources_locations_response',
              'toatechResourcemanagement10.GetResourcesLocationsResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.GetResourcesListResponseElement get_resources_list(toatechResourcemanagement10.AuthNodeElement user_x,String root_resource_id,String include_children,Integer select_from,Integer select_count,String date_x,toatechResourcemanagement10.RequiredPropertiesElement required_properties) {
            toatechResourcemanagement10.GetResourcesListElement request_x = new toatechResourcemanagement10.GetResourcesListElement();
            request_x.user_x = user_x;
            request_x.root_resource_id = root_resource_id;
            request_x.include_children = include_children;
            request_x.select_from = select_from;
            request_x.select_count = select_count;
            request_x.date_x = date_x;
            request_x.required_properties = required_properties;
            toatechResourcemanagement10.GetResourcesListResponseElement response_x;
            Map<String, toatechResourcemanagement10.GetResourcesListResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.GetResourcesListResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/get_resources_list',
              'urn:toatech:ResourceManagement:1.0',
              'get_resources_list',
              'urn:toatech:ResourceManagement:1.0',
              'get_resources_list_response',
              'toatechResourcemanagement10.GetResourcesListResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.SetLocationsResponseElement update_locations(toatechResourcemanagement10.AuthNodeElement user_x,toatechResourcemanagement10.LocationList locations) {
            toatechResourcemanagement10.SetLocationsElement request_x = new toatechResourcemanagement10.SetLocationsElement();
            request_x.user_x = user_x;
            request_x.locations = locations;
            toatechResourcemanagement10.SetLocationsResponseElement response_x;
            Map<String, toatechResourcemanagement10.SetLocationsResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.SetLocationsResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/update_locations',
              'urn:toatech:ResourceManagement:1.0',
              'update_locations',
              'urn:toatech:ResourceManagement:1.0',
              'update_locations_response',
              'toatechResourcemanagement10.SetLocationsResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.GetUserResponseElement get_user(toatechResourcemanagement10.AuthNodeElement user_x,String login) {
            toatechResourcemanagement10.GetUserElement request_x = new toatechResourcemanagement10.GetUserElement();
            request_x.user_x = user_x;
            request_x.login = login;
            toatechResourcemanagement10.GetUserResponseElement response_x;
            Map<String, toatechResourcemanagement10.GetUserResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.GetUserResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/get_user',
              'urn:toatech:ResourceManagement:1.0',
              'get_user',
              'urn:toatech:ResourceManagement:1.0',
              'get_user_response',
              'toatechResourcemanagement10.GetUserResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.SetResourcesSkillsResponseElement set_resources_skills(toatechResourcemanagement10.AuthNodeElement user_x,toatechResourcemanagement10.SkillList skills) {
            toatechResourcemanagement10.SetResourcesSkillsElement request_x = new toatechResourcemanagement10.SetResourcesSkillsElement();
            request_x.user_x = user_x;
            request_x.skills = skills;
            toatechResourcemanagement10.SetResourcesSkillsResponseElement response_x;
            Map<String, toatechResourcemanagement10.SetResourcesSkillsResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.SetResourcesSkillsResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/set_resources_skills',
              'urn:toatech:ResourceManagement:1.0',
              'set_resources_skills',
              'urn:toatech:ResourceManagement:1.0',
              'set_resources_skills_response',
              'toatechResourcemanagement10.SetResourcesSkillsResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.SetLocationsResponseElement delete_locations(toatechResourcemanagement10.AuthNodeElement user_x,toatechResourcemanagement10.LocationList locations) {
            toatechResourcemanagement10.SetLocationsElement request_x = new toatechResourcemanagement10.SetLocationsElement();
            request_x.user_x = user_x;
            request_x.locations = locations;
            toatechResourcemanagement10.SetLocationsResponseElement response_x;
            Map<String, toatechResourcemanagement10.SetLocationsResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.SetLocationsResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/delete_locations',
              'urn:toatech:ResourceManagement:1.0',
              'delete_locations',
              'urn:toatech:ResourceManagement:1.0',
              'delete_locations_response',
              'toatechResourcemanagement10.SetLocationsResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.GetLocationsResponseElement get_locations(toatechResourcemanagement10.AuthNodeElement user_x,toatechResourcemanagement10.LocationResourceParamsList resources) {
            toatechResourcemanagement10.GetLocationsElement request_x = new toatechResourcemanagement10.GetLocationsElement();
            request_x.user_x = user_x;
            request_x.resources = resources;
            toatechResourcemanagement10.GetLocationsResponseElement response_x;
            Map<String, toatechResourcemanagement10.GetLocationsResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.GetLocationsResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/get_locations',
              'urn:toatech:ResourceManagement:1.0',
              'get_locations',
              'urn:toatech:ResourceManagement:1.0',
              'get_locations_response',
              'toatechResourcemanagement10.GetLocationsResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.GetResourcesZonesResponseElement get_resources_zones(toatechResourcemanagement10.AuthNodeElement user_x,toatechResourcemanagement10.GetResourcesParamsList resources) {
            toatechResourcemanagement10.GetResourcesZonesElement request_x = new toatechResourcemanagement10.GetResourcesZonesElement();
            request_x.user_x = user_x;
            request_x.resources = resources;
            toatechResourcemanagement10.GetResourcesZonesResponseElement response_x;
            Map<String, toatechResourcemanagement10.GetResourcesZonesResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.GetResourcesZonesResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/get_resources_zones',
              'urn:toatech:ResourceManagement:1.0',
              'get_resources_zones',
              'urn:toatech:ResourceManagement:1.0',
              'get_resources_zones_response',
              'toatechResourcemanagement10.GetResourcesZonesResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public toatechResourcemanagement10.GetResourcesSkillsResponseElement get_resources_skills(toatechResourcemanagement10.AuthNodeElement user_x,String expand_complex_skills,toatechResourcemanagement10.GetResourcesParamsList resources) {
            toatechResourcemanagement10.GetResourcesSkillsElement request_x = new toatechResourcemanagement10.GetResourcesSkillsElement();
            request_x.user_x = user_x;
            request_x.expand_complex_skills = expand_complex_skills;
            request_x.resources = resources;
            toatechResourcemanagement10.GetResourcesSkillsResponseElement response_x;
            Map<String, toatechResourcemanagement10.GetResourcesSkillsResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.GetResourcesSkillsResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/get_resources_skills',
              'urn:toatech:ResourceManagement:1.0',
              'get_resources_skills',
              'urn:toatech:ResourceManagement:1.0',
              'get_resources_skills_response',
              'toatechResourcemanagement10.GetResourcesSkillsResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        */
        public toatechResourcemanagement10.GetResourcesCalendarsResponseElement get_resources_calendars(toatechResourcemanagement10.AuthNodeElement user_x,toatechResourcemanagement10.GetResourcesParamsList resources) {
            toatechResourcemanagement10.GetResourcesCalendarsElement request_x = new toatechResourcemanagement10.GetResourcesCalendarsElement();
            request_x.user_x = user_x;
            request_x.resources = resources;
            toatechResourcemanagement10.GetResourcesCalendarsResponseElement response_x;
            Map<String, toatechResourcemanagement10.GetResourcesCalendarsResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.GetResourcesCalendarsResponseElement>();
            response_map_x.put('response_x', response_x);
            if(!Test.isRunningTest()){
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/get_resources_calendars',
              'urn:toatech:ResourceManagement:1.0',
              'get_resources_calendars',
              'urn:toatech:ResourceManagement:1.0',
              'get_resources_calendars_response',
              'toatechResourcemanagement10.GetResourcesCalendarsResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            }
            else{//Fake Response for Test Coverage
            
            toatechResourcemanagement10.TextPropertyElement textpropEle=new toatechResourcemanagement10.TextPropertyElement();
             textpropEle.name='calendar_type';
             textpropEle.value='working';
             textpropEle.name='date';
             textpropEle.value=string.valueof(Date.Today());
             textpropEle.name='time_to';
             textpropEle.value='19:00';
             textpropEle.name='time_from';
             textpropEle.value='09:00';
             textpropEle.name='resource_id';
             textpropEle.value='a0A20000002RrQbEAK';
             toatechResourcemanagement10.TextPropertyElement[] textPropEleList=new toatechResourcemanagement10.TextPropertyElement[]{textpropEle};
            
             toatechResourcemanagement10.TextPropertiesElement textProesEle=new toatechResourcemanagement10.TextPropertiesElement();
             textProesEle.property=textPropEleList;
             toatechResourcemanagement10.CalendarElement calEle=new toatechResourcemanagement10.CalendarElement();
             calEle.properties=textProesEle;
             toatechResourcemanagement10.CalendarElement[] calEleList =new toatechResourcemanagement10.CalendarElement[]{calEle};
             //calEleList.add(calEle);
             toatechResourcemanagement10.CalendarList calList=new toatechResourcemanagement10.CalendarList();
             calList.calendar=calEleList;
             toatechResourcemanagement10.GetResourcesCalendarsResponseElement respEle=new toatechResourcemanagement10.GetResourcesCalendarsResponseElement();
             respEle.calendars=calList;
             response_x=respEle;
            
            }
            return response_x;
        }
        /*
        public toatechResourcemanagement10.SetUserResponseElement insert_user(toatechResourcemanagement10.AuthNodeElement user_x,String login,toatechResourcemanagement10.PropertiesElement properties,toatechResourcemanagement10.ResourceIdListElement resources) {
            toatechResourcemanagement10.InsertUserElement request_x = new toatechResourcemanagement10.InsertUserElement();
            request_x.user_x = user_x;
            request_x.login = login;
            request_x.properties = properties;
            request_x.resources = resources;
            toatechResourcemanagement10.SetUserResponseElement response_x;
            Map<String, toatechResourcemanagement10.SetUserResponseElement> response_map_x = new Map<String, toatechResourcemanagement10.SetUserResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ResourceManagementService/insert_user',
              'urn:toatech:ResourceManagement:1.0',
              'insert_user',
              'urn:toatech:ResourceManagement:1.0',
              'insert_user_response',
              'toatechResourcemanagement10.SetUserResponseElement'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        */
    }
}