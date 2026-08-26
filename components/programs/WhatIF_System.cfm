<!------------------------------------------------------------------------------------------------------------------------------------------

	File:		\components\programs\WhatIF_System.cfm
	Author:		Chris Nguyen
	Date:		2014 October
	Purpose:	Gather what if system values in create new option and in reset option

	Remarks:	This logic is used in more than one place and therefore it is defined as a CF include

	CF Input Variables:

		local.item         =  has BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
		local.shr_ship_to  =  for looking up pricing information

	SQL Output Variables:

        ,@component_cost DECIMAL( 20, 2 )
        ,@dvl DECIMAL( 20, 2 )
        ,@equip_cema DECIMAL( 20, 2 )
        ,@fixed_cost DECIMAL( 20, 2 )
        ,@net_sales DECIMAL( 20, 2 )
        ,@net_weight VARCHAR(50)
        ,@packaging DECIMAL( 20, 2 )
        ,@raw_material DECIMAL( 20, 2 )
		,@tpa DECIMAL( 20, 2 )
------------------------------------------------------------------------------------------------------------------------------------------->

	DECLARE @list_price DECIMAL( 20, 2 ) = 0
	        ,@component_cost DECIMAL( 20, 2 ) = 0
	        ,@cost DECIMAL( 20, 2 ) = 0
	        ,@dvl DECIMAL( 20, 2 ) = 0
	        ,@dnt DECIMAL( 20, 2 ) = 0
	        ,@equip_cema DECIMAL( 20, 2 ) = 0
	        ,@fixed_cost DECIMAL( 20, 2 ) = 0
	        ,@foo VARCHAR(50)
	        ,@net_sales DECIMAL( 20, 2 ) = 0
	        ,@net_weight VARCHAR(50) = '0'
	        ,@packaging DECIMAL( 20, 2 ) = 0
	        ,@raw_material DECIMAL( 20, 2 ) = 0
	        ,@opr_income DECIMAL( 20, 2 ) = 0
	        ,@opr_margin DECIMAL( 20, 2 ) = 0
			,@tpa DECIMAL( 20, 2 ) = 0
			,@cash_discount DECIMAL( 20, 2 ) = 0
			,@local_cost_variables BIT
			,@Product_Id    UNIQUEIDENTIFIER
        	,@Type_Code_Desc_Id NVARCHAR(100)


	SELECT @local_cost_variables = local_cost_variables from _application_settings

	IF object_id('tempdb..#tmp_prod_cust') is not null
		DROP TABLE #tmp_prod_cust

	SELECT i.bsa_FoodService_Items_Master_Id
	       ,c.bsa_FoodService_Customers_Id
	       ,Cast( NULL AS DECIMAL( 20, 2 )) AS Price
	  INTO #tmp_prod_cust
	  FROM bsa_FoodService_Items_Master i
	       INNER JOIN bsa_FoodService_Customers c ON c.shr_Ship_To = <cfoutput>'#local.shr_ship_to#'</cfoutput>
	 WHERE i.bsa_FoodService_Items_Master_ID = <cfoutput>'#local.item#'</cfoutput>

	SELECT @Product_Id = bsa_FoodService_Items_Master_Id FROM #tmp_prod_cust

	<!--- For each distributor / product get the price from gross margin table --->
	UPDATE #tmp_prod_cust
	   SET Price = gm.cs_del_Price
	  FROM #tmp_prod_cust
	       INNER JOIN Gross_Margin gm ON gm.Product_Id = bsa_FoodService_Items_Master_Id
	                                     AND gm.Customer_Id = bsa_FoodService_Customers_Id


	<!--- If any distributor / product don't have a price in gross margin table, get price from  ITEM_MARGIN_TARGETS for that combination --->
	UPDATE #tmp_prod_cust
	   SET Price = t.Item_del_Base_Price
	  FROM #tmp_prod_cust
	       INNER JOIN Item_Margin_Targets t ON t.Product_Id = bsa_FoodService_Items_Master_Id
	 WHERE #tmp_Prod_cUst.Price IS NULL


	SELECT @foo = bsa_FoodService_Items_Master_Id
	       ,@list_price = avg( Price )
	  FROM #tmp_prod_cust
	 WHERE Price != 0
	 GROUP BY bsa_FoodService_Items_Master_Id

	SELECT   @net_weight   = Net_Weight
			,@raw_material = IsNull(del_del_Cost, 0)
			,@packaging    = IsNull(del_cUst_Pickup, 0)
			,@dvl          = IsNull(var_Man_Cost, 0)
			,@dnt          = IsNull(Del_frt_cost, 0)
			,@fixed_cost   = IsNull(fx_Man_Cost, 0)
			,@equip_cema   = IsNull(del_var_Warhs, 0)
			,@Type_Code_Desc_Id = Type_Code_Desc_Id
	  FROM Bsa_FoodService_Items_Master
	 WHERE bsa_FoodService_Items_Master_ID = <cfoutput>'#local.item#'</cfoutput>


	IF object_id('tempdb..#Tmp_Program_Distributors_Trade_Rate_DIST') is not null
		DROP TABLE #Tmp_Program_Distributors_Trade_Rate_DIST

	SELECT pdt.bsa_FoodService_Customers_Id
	       ,pdt.bsa_FoodService_Items_Master_Id
	       ,pdt.tPa_Record_Type
	       ,Sum( Cast( pdt.Rate AS FLOAT ) ) AS Rate
	  INTO #Tmp_Program_Distributors_Trade_Rate_DIST
	  FROM Program_Distributors_Trade pdt
	WHERE tPa_Record_Type = 0
			AND EXISTS ( SELECT *
			               FROM #tmp_prod_cust
			              WHERE #tmp_prod_cust.bsa_FoodService_Customers_Id = pdt.bsa_FoodService_Customers_Id )
		AND pdt.bsa_FoodService_Items_Master_Id = <cfoutput>'#local.item#'</cfoutput>
	GROUP BY pdt.bsa_FoodService_Customers_Id
	          ,pdt.bsa_FoodService_Items_Master_Id
	          ,pdt.tPa_Record_Type


	IF object_id('tempdb..#PRODUCT_TRADE_MARGIN_DIST') is not null
		DROP TABLE #PRODUCT_TRADE_MARGIN_DIST

	SELECT pdtr.bsa_FoodService_Items_Master_Id
	       ,pdtr.tPa_Record_Type
	       ,IsNull( avg( Cast( IsNull( pdtr.Rate, 0 ) AS FLOAT ) ), 0 ) AS tPa
	  INTO #PRODUCT_TRADE_MARGIN_DIST
	  FROM #Tmp_Program_Distributors_Trade_Rate_DIST pdtr
	GROUP BY pdtr.bsa_FoodService_Items_Master_Id
	          ,pdtr.tPa_Record_Type


	<!--- This is the TPA per product --->
	SELECT @tpa = ISNULL(tPa, 0)
	  FROM #PRODUCT_TRADE_MARGIN_DIST
	WHERE tPa_Record_Type = 0

	<!--- This is the Component Cost per product --->
	SELECT @component_cost = ISNULL(tPa, 0)
	  FROM #PRODUCT_TRADE_MARGIN_DIST
	WHERE tPa_Record_Type = 1

	SELECT @cash_discount = CASE ITEM_DEFAULT_TYPE
	                             WHEN 'F' THEN ITEM_FOB_CASH_DISCOUNT
	                             ELSE ITEM_DEL_CASH_DISCOUNT
	                        END
     FROM Item_Margin_Targets
	WHERE Product_Id = @Product_Id

	IF @local_cost_variables = 1
	BEGIN

      DECLARE @costvariablescount INT

      SET @cash_discount = @List_Price
      SELECT @costvariablescount = count(*)
        FROM Cost_Sequence
       WHERE deleted = 0

      IF @costvariablescount > 0
      BEGIN
            DECLARE @MyCounter INT,
                    @cost_fieldname nvarchar(50),
                    @cost_uom_fieldname nvarchar(50),
                    @MySQL nvarchar(2000),
                    @cost_val decimal(20, 4),
                    @cost_uom int

            SET @MyCounter = 1

            WHILE (@MyCounter < @costvariablescount + 1)
            BEGIN

                  IF @cash_discount != 0
                  BEGIN
                        IF Object_Id( 'tempdb..#Tmp_cost_vars' ) IS NOT NULL
                          DROP TABLE #Tmp_cost_vars
                        CREATE TABLE #Tmp_cost_vars (val decimal(20, 4), uom int)

                        SET @cost_fieldname      =  'cost'+cast(@MyCounter as nvarchar(4))+'_rate'
                        SET @cost_uom_fieldname  =  'cost'+cast(@MyCounter as nvarchar(4))+'_uom'

                        DECLARE @cost_rate nvarchar(50)

                        SELECT @MySQL = N'
                        SELECT      ' + @cost_fieldname + ', ' + @cost_uom_fieldname + '
                          FROM  Group_Local_Costs
                         WHERE group_id = ''' + @Type_Code_Desc_Id + ''''

                        INSERT INTO #Tmp_cost_vars
                        EXEC (@MySQL)

                        SELECT      @cost_val = val,
                                    @cost_uom = uom
                          FROM  #Tmp_cost_vars

                        SET @cash_discount = @cash_discount -
                                                (CASE WHEN @cost_val != 0 THEN
                                                      CASE WHEN @cost_uom = 1 THEN @cost_val
                                                           WHEN @cost_uom = 2 THEN @cost_val * @net_weight
                                                           ELSE (@cost_val  * @cash_discount)/100
                                                      END
                                                      ELSE 0
                                                END)
                  END

                  SET @MyCounter = @MyCounter + 1
            END

      END

      IF @List_Price != 0
      	SET @cash_discount = @List_Price - @cash_discount
	END

IF @local_cost_variables = 2
	BEGIN

      SELECT      @cash_discount = ISNULL((#tmp_prod_cust.price * bsa_foodservice_customers.Cash_Discount), 0)
        FROM  #tmp_prod_cust INNER JOIN bsa_foodservice_customers
      			ON    bsa_foodservice_customers.bsa_foodservice_customers_id = #tmp_prod_cust.bsa_FoodService_Customers_Id
	END


	SELECT  @net_sales = @list_price - @tpa
           ,@cost = (@raw_material + @packaging + @dvl + @fixed_cost + @dnt + @equip_cema + @component_cost)
           ,@opr_income = @net_sales - @cost
           ,@tpa = @tpa * @net_weight
           ,@opr_margin = CASE
                              WHEN @list_price = 0 THEN 0
                              ELSE ( @opr_income / @list_price ) * 100
                          END
