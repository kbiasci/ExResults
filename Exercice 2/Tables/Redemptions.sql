CREATE TABLE [dbo].[Redemptions]
(
    [UserId] INT NOT NULL, 
    [CouponId] INT NOT NULL, 
    [RedemptionDate] DATETIME2 NOT NULL DEFAULT GETDATE(), 
    [UniqueCode] NVARCHAR(50) NOT NULL, 
    CONSTRAINT [PK_Offers] PRIMARY KEY ([UserId], [CouponId], [RedemptionDate], [UniqueCode]),
    CONSTRAINT [FK_Redemptions_Users] FOREIGN KEY ([UserId]) REFERENCES [Users]([Id]),
    CONSTRAINT [FK_Redemptions_Coupons] FOREIGN KEY ([CouponId]) REFERENCES [Coupons]([Id]),
)

GO

CREATE NONCLUSTERED INDEX [IX_Redemptions_UserId]
    ON [dbo].[Redemptions]([UserId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_Redemptions_CouponId]
    ON [dbo].[Redemptions]([CouponId] ASC);
GO


CREATE NONCLUSTERED INDEX [IX_Redemptions_UniqueCode]
    ON [dbo].[Redemptions]([UniqueCode] ASC);
GO

CREATE NONCLUSTERED INDEX [IDX_Redemptions_AllColumns]
    ON [dbo].[Redemptions]([UserId] ASC, [CouponId] ASC, [RedemptionDate] ASC, [UniqueCode] ASC);
GO

CREATE TRIGGER [dbo].[Trigger_Redemptions]
    ON [dbo].[Redemptions]
    INSTEAD OF INSERT
    AS
    BEGIN
        SET NoCount ON	

		DECLARE @UserId INT
		DECLARE @CouponId INT
		DECLARE @RedemptionDate DATETIME2
		DECLARE @UniqueCode NVARCHAR(50)

		SELECT @UserId = inserted.UserId, @CouponId = inserted.CouponId, @RedemptionDate = inserted.RedemptionDate, @UniqueCode = inserted.UniqueCode FROm inserted

        DECLARE @CurrentNbOfRedemptionsForThisCoupon INT
        SET @CurrentNbOfRedemptionsForThisCoupon = ( SELECT COUNT(Redemptions.CouponId) FROM Redemptions		
		where Redemptions.CouponId = @CouponId)
        
        DECLARE @CurrentNbOfRedemptionsPerUser INT
        SET @CurrentNbOfRedemptionsPerUser = ( SELECT COUNT( Redemptions.CouponId) FROM Redemptions 
		where Redemptions.UserId = @UserId AND Redemptions.CouponId = @CouponId)
    
        DECLARE @MaxRedemptionsinTotalForThisCoupon INT
        DECLARE @MaxRedemptionsPerUserForThisCoupon INT
        SELECT @MaxRedemptionsinTotalForThisCoupon = Coupons.MaxNbInTotal, @MaxRedemptionsPerUserForThisCoupon = Coupons.MaxNbPerUser from Coupons 
		WHERE Coupons.Id = @CouponId

        IF (@CurrentNbOfRedemptionsForThisCoupon >= @MaxRedemptionsinTotalForThisCoupon OR @CurrentNbOfRedemptionsPerUser >= @MaxRedemptionsPerUserForThisCoupon)
        BEGIN			
            RAISERROR ('Max Number of redemptions has been reached for this coupon.' ,10,1)
			ROLLBACK TRANSACTION;
			RETURN;
        END
        ELSE
        BEGIN            
			INSERT Redemptions SELECT inserted.UserId, inserted.CouponId, inserted.RedemptionDate, inserted.UniqueCode FROM inserted			
        END 
      
    END