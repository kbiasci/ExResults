CREATE VIEW [dbo].[CouponsReportingView]
	AS SELECT 
	c.Id, c.Title, c.MaxNbInTotal, c.MaxNbPerUser
	FROM [Redemptions] r
	LEFT JOIN [Coupons] c ON r.CouponId = c.Id
	LEFT JOIN [Users] u ON r.UserId = u.Id

