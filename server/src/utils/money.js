export function calculateQuotation(items) {
 if(!Array.isArray(items)||items.length===0) throw new Error('At least one quotation item is required');
 let subtotal=0,discountTotal=0,gstTotal=0;
 const calculated=items.map((item)=>{
  const quantity=Number(item.quantity), unitPrice=Number(item.unit_price), discountPct=Number(item.discount_pct??0), gstPct=Number(item.gst_pct??18);
  if(!Number.isInteger(quantity)||quantity<=0||!Number.isFinite(unitPrice)||unitPrice<0||discountPct<0||discountPct>100||gstPct<0||gstPct>100) throw new Error('Invalid quotation item values');
  const base=quantity*unitPrice, discount=base*discountPct/100, taxable=base-discount, gst=taxable*gstPct/100;
  const line=Number((taxable+gst).toFixed(2)); subtotal+=base; discountTotal+=discount; gstTotal+=gst;
  return {...item,quantity,unit_price:unitPrice,discount_pct:discountPct,gst_pct:gstPct,line_amount:line};
 });
 return {items:calculated,subtotal:Number(subtotal.toFixed(2)),discount_total:Number(discountTotal.toFixed(2)),gst_total:Number(gstTotal.toFixed(2)),grand_total:Number((subtotal-discountTotal+gstTotal).toFixed(2))};
}
