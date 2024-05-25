/*
Cleaning data in Sql Queries
*/

select * from NashvilleHousing

--Standardise date format

select SaleDate,Convert(date,SaleDate) from NashvilleHousing

update NashvilleHousing set
SaleDateConverted=Convert(date,SaleDate)

Alter table NashvilleHousing
ADD SaleDateConverted Date

Select SaleDate,SaleDateConverted  from NashvilleHousing

--Populate property Address data

select PropertyAddress from NashvilleHousing

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking Address into Address,city,State

select 
Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from NashvilleHousing

Alter table NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress=Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

update NashvilleHousing
set PropertySplitCity=Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Alter table NashvilleHousing
ADD PropertySplitCity nvarchar(255)

select PropertySplitAddress,PropertySplitCity  from NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
OwnerAddress from NashvilleHousing

alter table NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)


alter table NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

alter table NashvilleHousing
ADD OwnerSplitState nvarchar(255)


update NashvilleHousing
set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)


update NashvilleHousing
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)



update NashvilleHousing
set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select OwnerSplitAddress,OwnerSplitCity,OwnerSplitState  from NashvilleHousing


--Change Y and N to Yes and No in SoldAsVacant

select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) from NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant

Select SoldAsVacant,
CASE When SoldAsVacant='Y' Then 'Yes'
     When SoldAsVacant='N' Then 'No'
	 ELSE SoldAsVacant
	 End
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant=CASE When SoldAsVacant='Y' Then 'Yes'
     When SoldAsVacant='N' Then 'No'
	 ELSE SoldAsVacant
	 End


--Remove duplicates

With RowNumCTE as(
select *,
ROW_NUMBER() OVER 
(partition by ParcelID,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference
Order by UniqueID)row_num
from NashvilleHousing
--order by ParcelID
)

Select * from RowNumCTE
where row_num>1
order by PropertyAddress


--Delete unused columns

select * from NashvilleHousing

Alter table NashvilleHousing
Drop Column OwnerAddress,PropertyAddress,TaxDistrict

Alter table NashvilleHousing
Drop Column SaleDate

