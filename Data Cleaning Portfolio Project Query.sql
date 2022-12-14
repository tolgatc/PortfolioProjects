/*

Cleaning Data in SQL Queries

*/


Select *
From [Portfolio project].dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDataConverted, CONVERT(Date,SaleDate)
From [Portfolio project].dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate =CONVERT(Date,SaleDate) 

Alter table NashvilleHousing
Add SaleDataConverted Date;

Update NashvilleHousing
Set SaleDataConverted =CONVERT(Date,SaleDate) 
--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From [Portfolio project].dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio project].dbo.NashvilleHousing a
JOIN [Portfolio project].dbo.NashvilleHousing B
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <>b.[UniqueID ]
Where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio project].dbo.NashvilleHousing a
JOIN [Portfolio project].dbo.NashvilleHousing B
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <>b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio project].dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

select
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City

Select *
From [Portfolio project].dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddres Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddres =substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity =substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
From [Portfolio project].dbo.NashvilleHousing

Select OwnerAddress
From [Portfolio project].dbo.NashvilleHousing

Select
parsename(REPLACE(OwnerAddress,',','.'),3)
,parsename(REPLACE(OwnerAddress,',','.'),2)
,parsename(REPLACE(OwnerAddress,',','.'),1)
From [Portfolio project].dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress =parsename(REPLACE(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity =parsename(REPLACE(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState  =parsename(REPLACE(OwnerAddress,',','.'),1)

Select *
From [Portfolio project].dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), count(SoldAsVacant)
From [Portfolio project].dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No' 
else SoldAsVacant
end
From [Portfolio project].dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No' 
else SoldAsVacant
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE as(
Select *, 
	row_number() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
				UniqueID
				) row_num
from [Portfolio project].dbo.NashvilleHousing
--order by ParcelID
)
--where row_num>1

select *
from RowNumCTE
where row_num>1
--order by PropertyAddress
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from [Portfolio project].dbo.NashvilleHousing

alter table [Portfolio project].dbo.NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress,

alter table [Portfolio project].dbo.NashvilleHousing
drop column SaleDate











-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















