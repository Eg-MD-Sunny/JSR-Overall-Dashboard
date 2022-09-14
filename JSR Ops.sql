--Total Cancelled

Select cast(dbo.tobdt(sst.createdon) as date) CancelledDate,
	count(distinct case when s.WarehouseId=25 then s.id else Null end) JSR
from ShipmentStateTransition sst
join Shipment s on s.id=sst.ShipmentId
Where cast(dbo.tobdt(sst.createdon) as date)>='2021-07-14'
and cast(dbo.tobdt(sst.createdon) as date)<'2021-07-15'
and sst.ToState=9
group by  cast(dbo.tobdt(sst.createdon) as date)
order by 1 desc

-- CancelledAfterPickup

select cast(csap.CreatedOn as date) CancelledDate,
	count(distinct case when s.WarehouseId=25 then s.id else Null end) JSR
from shipment s
join CancelledShipmentAfterPickup csap on csap.id=s.id
where 
cast(csap.CreatedOn as date)>='2021-07-14'
and cast(csap.CreatedOn as date)<'2021-07-15'
group by cast(csap.CreatedOn as date)
order by 1 desc


--Rescheduled Shipment Count 

Select cast(s.deliverywindowend as date) DeliveryDate,
	count(distinct case when s.WarehouseId=25 then s.id else Null end) JSR
from shipment s 
where cast(s.deliverywindowend as date)>='2021-07-14'
and cast(s.deliverywindowend as date)<'2021-07-15'
and RescheduledShipmentId is not null
group by cast(s.deliverywindowend as date)
order by 1 desc

-- ReconciledOrders

select CAST(dbo.tobdt(reconciledon) as DATE) ReconciledDate,
	count(distinct case when s.WarehouseId=25 then s.id else Null end) JSR
from shipment s
where reconciledon is NOT NULL
and CAST(dbo.tobdt(reconciledon) as DATE) >='2021-07-14'
and CAST(dbo.tobdt(reconciledon) as DATE) <'2021-07-15'
group by CAST(dbo.tobdt(reconciledon) as DATE)
order by 1 desc

-- Fulfilled Percentage

select t.ReconciledDate, 
	(case when t.Id = 25 then t.FulfilledPercentage end) JSR
from (select CAST(dbo.tobdt(reconciledon) as DATE) ReconciledDate,w.id,w.name,
concat(
convert(decimal(10,2),(count(*)-sum(case when tr.hasfailedbeforedispatch=1 then 1 else 0 end))*100.00/cast(count(*) as float)),'%') FulfilledPercentage
from shipment s
join warehouse w on w.id=s.WarehouseId
join thingrequest tr on tr.shipmentid=s.id
where reconciledon is NOT NULL
and CAST(dbo.tobdt(reconciledon) as DATE) >='2021-07-14'
and CAST(dbo.tobdt(reconciledon) as DATE) <'2021-07-15'
and w.id in (25)
group by CAST(dbo.tobdt(reconciledon) as DATE),w.id,w.name
) t
order by 1 desc
