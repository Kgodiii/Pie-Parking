package com.example.historyscreen;

public class HistoryItem {
    private String id;
    private String locationName;
    private String datePaid;
    private String amount;

    // Empty constructor required for Gson
    public HistoryItem() {}

    public String getId() { return id; }
    public String getLocationName() { return locationName; }
    public String getTransactionDate() { return datePaid; }
    public String getAmount() { return amount; }
}


