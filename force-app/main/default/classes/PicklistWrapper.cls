public class PicklistWrapper {
        public String value {get;set;}
        public Boolean isSelected {get;set;}
        public String Label {get;set;}        
        public PicklistWrapper(String Label,String value, Boolean isSelected) {
            this.value = value;
            this.isSelected = isSelected;
            this.Label=label;
        }
    }