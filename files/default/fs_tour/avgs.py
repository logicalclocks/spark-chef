import hsfs
import pandas as pd
import numpy as np

# Setup feature store connection
connection = hsfs.connection()
fs = connection.get_feature_store()

# Fetch raw features from the on-demand feature group
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
# Rate of Change
# Even more common is to want the rate of change as expressed by percent change. Pandas has the handy pct_change() method for this purpose, but beware that you'll get odd behavior if you mix this
# with groupby() as shown above. I prefer to create my own lambda wrapper function as shown below.
pct_chg_fxn = lambda x: x.pct_change()
feature_group_data["ask_volume_percent_change"] = midprice.groupby(
    level="symbol"
).ask_volume.apply(pct_chg_fxn)

# Moving Averages
# Sometimes, we'd rather use the moving average of a value as part of a feature. This can be the value itself if you want to minimize how "jittery" a value is. Or, more commonly, you may want to
# compare a value with a trailing moving average of itself. Again, we need to use groupby since our dataframe has info on multiple symbols - and again, we need to use a lambda function wrapper
# to avoid error. There are other patterns which will accomplish the same thing but I find this to be cleanest.

# daily closing price vs. 50 hours exponential moving avg
ema_50 = lambda x: x.ewm(span=50).mean()
feature_group_data["price_exp_moving_average"] = (
    midprice.close / midprice.close.groupby(level="symbol").apply(ema_50) - 1
)

zscore_fun_improved = (
    lambda x: (x - x.rolling(window=20, min_periods=2).mean())
    / x.rolling(window=20, min_periods=2).std()
)
feature_group_data["close_price_zscore"] = midprice.groupby(level="symbol").close.apply(
    zscore_fun_improved
)

feature_group_data.reset_index(inplace=True)

# Write the output to the feature store
avgs_fg = fs.create_feature_group(
    name="forex_avgs",
    version=1,
    primary_key=["symbol"],
    event_time="date",
    description="Averages for the forex echange",
    time_travel_format="HUDI",
    online_enabled=True,
    statistics_config={"enabled": True, "histograms": True, "correlations": True},
)

avgs_fg.save(
    feature_group_data,
    {
        "hoodie.bulkinsert.shuffle.parallelism": "1",
        "hoodie.insert.shuffle.parallelism": "1",
        "hoodie.upsert.shuffle.parallelism": "1",
        "hoodie.parquet.compression.ratio": "0.5",
    },
)
