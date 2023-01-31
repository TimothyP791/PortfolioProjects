/*

Cleaning Data in SQL Queries

*/

Select * 
From PortfolioProject3.dbo.NashvilleHousing
-----------------------------------------------------------------------------------
--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject3.dbo.NashvilleHousing

--Update NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)




------------------------------------------------------------------------------------
--Populate Property Address Data

Select *
From PortfolioProject3.dbo.NashvilleHousing
--Where PropertyAddress Is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) --IsNull(item that is null,what we want to populate with)
From PortfolioProject3.dbo.NashvilleHousing a
JOIN PortfolioProject3.dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject3.dbo.NashvilleHousing a
JOIN PortfolioProject3.dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

-------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)



Select PropertyAddress
From PortfolioProject3.dbo.NashvilleHousing
--Where PropertyAddress Is null
--Order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address --CHARINDEX('What you're looking for', Column you're looking in): -1 gets rid of comma
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From PortfolioProject3.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




Select OwnerAddress
From PortfolioProject3.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject3.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)




ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)




ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)



---------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject3.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END
From PortfolioProject3.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END



-------------------------------------------------------------------------------------------------

--Remove duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
				    UniqueID
					) row_num

From PortfolioProject3.dbo.NashvilleHousing
--order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



---------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From PortfolioProject3.dbo.NashvilleHousing


ALTER TABLE PortfolioProject3.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
