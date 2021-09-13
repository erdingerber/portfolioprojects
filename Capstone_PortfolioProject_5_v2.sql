---- Change Case Statements "Y" & "N" to Yes and No




Select *
From Project5_NashvilleHousing.dbo.NashvilleHousingData




---- Standardizing the Date Format




Select SaleDateConv, CONVERT(Date,SaleDate)
From Project5_NashvilleHousing.dbo.NashvilleHousingData

Update Project5_NashvilleHousing.dbo.NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)




---- Populate Property Address Data




Select *
From Project5_NashvilleHousing.dbo.NashvilleHousingData
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Project5_NashvilleHousing.dbo.NashvilleHousingData a
Join Project5_NashvilleHousing.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Project5_NashvilleHousing.dbo.NashvilleHousingData a
Join Project5_NashvilleHousing.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




---- Breaking Address out in to Individual Columns (Address, City, State)




Select PropertyAddress
From Project5_NashvilleHousing.dbo.NashvilleHousingData
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From Project5_NashvilleHousing.dbo.NashvilleHousingData

ALTER TABLE Project5_NashvilleHousing.dbo.NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update Project5_NashvilleHousing.dbo.NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Project5_NashvilleHousing.dbo.NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update Project5_NashvilleHousing.dbo.NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From Project5_NashvilleHousing.dbo.NashvilleHousingData


Select OwnerAddress
From Project5_NashvilleHousing.dbo.NashvilleHousingData


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Project5_NashvilleHousing.dbo.NashvilleHousingData

ALTER TABLE Project5_NashvilleHousing.dbo.NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update Project5_NashvilleHousing.dbo.NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Project5_NashvilleHousing.dbo.NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update Project5_NashvilleHousing.dbo.NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Project5_NashvilleHousing.dbo.NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update Project5_NashvilleHousing.dbo.NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From Project5_NashvilleHousing.dbo.NashvilleHousingData





-- Changing Y and N to "Yes" and "No" in the "Sold as Vacant" Field




Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Project5_NashvilleHousing.dbo.NashvilleHousingData
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Project5_NashvilleHousing.dbo.NashvilleHousingData


Update Project5_NashvilleHousing.dbo.NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END





-- REMOVING DUPLICATE ENTRIES




WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num

From Project5_NashvilleHousing.dbo.NashvilleHousingData
--Order By ParcelID
)
-- DELETE
Select *
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress

Select *
From Project5_NashvilleHousing.dbo.NashvilleHousingData




-- DELETING UNUSED COLUMNS --




Select *
From Project5_NashvilleHousing.dbo.NashvilleHousingData

ALTER TABLE Project5_NashvilleHousing.dbo.NashvilleHousingData
DROP Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate