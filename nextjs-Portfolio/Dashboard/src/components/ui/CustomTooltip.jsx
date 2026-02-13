const CustomTooltip = ({ active, payload, label }) => {
  if (active && payload && payload.length) {
    return (
      <div className="bg-white p-4 rounded-xl border border-slate-100 shadow-xl">
        <p className="text-sm font-medium text-slate-500 mb-1">{label}</p>
        <p className="text-lg font-bold text-violet-600">
          ${new Intl.NumberFormat("en-US").format(payload[0].value)}
        </p>
      </div>
    );
  }
  return null;
};

export default CustomTooltip;
