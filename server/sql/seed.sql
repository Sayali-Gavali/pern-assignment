USE pern_erp;
INSERT INTO products(id,product_code,product_name,category,unit,base_price) VALUES
(UUID(),'IND-001','Industrial Bearing 6204','Bearings','pcs',250.00),(UUID(),'IND-002','Steel Hex Bolt M10','Fasteners','pcs',12.50),(UUID(),'IND-003','Hydraulic Hose 1m','Hydraulics','m',480.00),(UUID(),'IND-004','Safety Valve 2in','Valves','pcs',1750.00),(UUID(),'IND-005','Drive Belt B-42','Power Transmission','pcs',320.00),(UUID(),'IND-006','Industrial Lubricant 5L','Lubricants','can',890.00) ON DUPLICATE KEY UPDATE product_name=VALUES(product_name);
INSERT IGNORE INTO inventory(product_id,physical_qty,reserved_qty) SELECT id, CASE product_code WHEN 'IND-001' THEN 200 WHEN 'IND-002' THEN 1000 WHEN 'IND-003' THEN 150 WHEN 'IND-004' THEN 60 WHEN 'IND-005' THEN 250 ELSE 90 END,0 FROM products;
