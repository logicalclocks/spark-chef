import hsfs
import pandas as pd
import numpy as np

# Setup a connection to the feature store
connection = hsfs.connection()
fs = connection.get_feature_store()

# Fetch raw features from on-demand feature groups
forex_ticks_fg = fs.get_on_demand_feature_group("forex_ticks", 1)
forex_ticks_pdf = forex_ticks_fg.read(dataframe_type="pandas")

# Feature engineering
forex_ticks_pdf["midprice"] = (
    forex_ticks_pdf.ask + forex_ticks_pdf.bid
) / 2.0

forex_ticks_pdf["date"] = pd.to_datetime(
    forex_ticks_pdf["date"], errors="coerce"
)
forex_ticks_pdf = forex_ticks_pdf.set_index("date")

grouped = forex_ticks_pdf.groupby("symbol")
ask = grouped["ask"].resample("1H").ohlc()
bid = grouped["bid"].resample("1H").ohlc()

midprice = grouped["midprice"].resample("1H").ohlc()
midprice["ask_volume"] = grouped["ask_volume"].resample("1H").mean()
midprice = midprice.reorder_levels(["date", "symbol"])

feature_group_data = pd.DataFrame()
feature_group_data["hourly_return"] = midprice.close / midprice.open - 1  # daily return
feature_group_data["hourly_moving_average"] = (
    midprice.open / midprice.groupby(level="symbol").close.shift(1) - 1
)

# Logs
# Many times, values like market cap, volume, revenue can map better to the prediction target if put into log space. This is easy to do via pandas+numpy:
feature_group_data["hourly_ask_volume_log"] = midprice.ask_volume.apply(
    np.log
)  # log of daily volume

# Differencing
# It's often more important to know how a value is changing than to know the value itself. The diff() method will calculate the change in value since the
# prior period (i.e., current minus prior). NOTE: the "groupby" is critically important since if it were omitted we would be comparing the difference in volume between symbols,
# which is not what we want.
feature_group_data["hourly_ask_volume_difference"] = midprice.groupby(
    level="symbol"
).ask_volume.diff()  # change since prior hour

feature_group_data.reset_index(inplace=True)

# Write data to the feature store
open_high_low_fg = fs.create_feature_group(
    name="open_high_low",
    version=1,
    primary_key=["symbol"],
    event_time="date",
    description="open, high, low features for the forex exchange",
    time_travel_format="HUDI",
    online_enabled=True,
    statistics_config={"enabled": True, "histograms": True, "correlations": True},
)

open_high_low_fg.save(
    feature_group_data,
    {
        "hoodie.bulkinsert.shuffle.parallelism": "1",
        "hoodie.insert.shuffle.parallelism": "1",
        "hoodie.upsert.shuffle.parallelism": "1",
        "hoodie.parquet.compression.ratio": "0.5",
    },
)

open_high_low_fg.add_tag('demo_tag', {
    'team_owner': 'demo_tour_users',
    'pii': True
})
