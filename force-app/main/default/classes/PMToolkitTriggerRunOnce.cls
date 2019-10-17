public with sharing class PMToolkitTriggerRunOnce {

    private static Set <Id> currentSet = new Set <Id>();

    public static void setIsCurrentlyRunning(Id objectId) {
        currentSet.add(objectId);
    }

    public static boolean isCurrentlyRunning(Id objectId) {
        return(currentSet.contains(objectId));
    }

    public static void removeCurrentlyRunning(Id objectId) {
        if(currentSet.contains(objectId)) {
            currentSet.remove(objectId);
        }
    }

    public static Integer countDone() {
    	return currentSet.size();
    }

    public static void resetAlreadyDone() {
        currentSet.clear();
    }
}