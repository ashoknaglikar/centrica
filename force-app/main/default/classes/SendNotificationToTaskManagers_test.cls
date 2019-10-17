@isTest

Private class SendNotificationToTaskManagers_test
{
        static testmethod void test() 
        {
             String context= '0 0 0 * * ? *';
             SchedulableContext sc;
             SendNotificationToTaskManagers Notify = new SendNotificationToTaskManagers();
             System.schedule('NotificationToTaskManagers',context, Notify);
             //SendNotificationToTaskManagers Notify = new SendNotificationToTaskManagers();
             Notify.execute(sc);

        }  
}