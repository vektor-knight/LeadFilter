trigger EmailTrigger on Account (after insert) {
    new AccountTriggerHandler().run();
}