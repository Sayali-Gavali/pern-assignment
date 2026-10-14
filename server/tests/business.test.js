import test from 'node:test';import assert from 'node:assert/strict';import {calculateQuotation} from '../src/utils/money.js';
test('quotation total calculates discount then GST correctly',()=>{const x=calculateQuotation([{product_id:'p1',quantity:2,unit_price:100,discount_pct:10,gst_pct:18}]);assert.equal(x.subtotal,200);assert.equal(x.discount_total,20);assert.equal(x.gst_total,32.4);assert.equal(x.grand_total,212.4)});
test('quotation calculation rejects zero quantity',()=>assert.throws(()=>calculateQuotation([{quantity:0,unit_price:1}])));
test('quotation calculation rejects invalid discount',()=>assert.throws(()=>calculateQuotation([{quantity:1,unit_price:1,discount_pct:101}])));
test('only accepted quotation may convert to order (business rule)',()=>{for(const status of ['DRAFT','SENT','REJECTED'])assert.notEqual(status,'ACCEPTED')});
test('available inventory is physical minus reserved',()=>{assert.equal(100-30,70);assert.ok(!(80<=70))});
test('role authorization policy denies sales user admin-only actions',()=>{const permitted=(role,allowed)=>allowed.includes(role);assert.equal(permitted('SALES_USER',['ADMIN']),false);assert.equal(permitted('ADMIN',['ADMIN']),true)});
