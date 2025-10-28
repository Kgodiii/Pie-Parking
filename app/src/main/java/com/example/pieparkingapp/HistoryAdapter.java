package com.example.pieparkingapp;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

public class HistoryAdapter extends RecyclerView.Adapter<HistoryAdapter.HistoryViewHolder> {

    private final List<HistoryItem> items;

    public HistoryAdapter(List<HistoryItem> items) {
        this.items = items;
    }

    @NonNull
    @Override
    public HistoryViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_history, parent, false);
        return new HistoryViewHolder(v);
    }

    @Override
    public void onBindViewHolder(@NonNull HistoryViewHolder holder, int position) {
        HistoryItem item = items.get(position);

        holder.tvLocation.setText(item.getLocationName() != null ? item.getLocationName() : "Unknown");
        holder.tvDate.setText(item.getTransactionDate() != null ? item.getTransactionDate() : "No Date");
        holder.tvAmount.setText(item.getAmount() != null ? "R " + item.getAmount() : "R 0.00");
    }

    @Override
    public int getItemCount() { return items.size(); }

    static class HistoryViewHolder extends RecyclerView.ViewHolder {
        TextView tvLocation, tvDate, tvAmount;
        public HistoryViewHolder(@NonNull View itemView) {
            super(itemView);
            tvLocation = itemView.findViewById(R.id.tvLocation);
            tvDate = itemView.findViewById(R.id.tvDate);
            tvAmount = itemView.findViewById(R.id.tvAmount);
        }
    }
}
