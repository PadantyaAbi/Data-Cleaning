select * 
from [dbo].[Nashville]

select saledate
from [dbo].[Nashville]

--ubah saledate jadi bentuk date
update Nashville
set SaleDate = convert(date,saledate)

--tambah kolom baru, data masih kosong
alter table Nashville
add TanggalAsli date;

--coba kita definisikan sebagai date dan cek
update Nashville
set TanggalAsli = convert(date,saledate)
select TanggalAsli
from [dbo].[Nashville]


--coba cek property address
select *
from [dbo].[Nashville]
where PropertyAddress is null
--kita mau ganti isi address yang null
select *
from [dbo].[Nashville]
order by ParcelID 
--Join
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from [dbo].[Nashville] a
join [dbo].[Nashville] b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null 

--gunakan ISNULL
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.propertyaddress, b.PropertyAddress) 
from [dbo].[Nashville] a
join [dbo].[Nashville] b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--lakukan UPDATE
UPDATE a 
Set PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress) 
from [dbo].[Nashville] a
join [dbo].[Nashville] b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--verifikasi sudah benar atau belum
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.propertyaddress, b.PropertyAddress) 
from [dbo].[Nashville] a
join [dbo].[Nashville] b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


--selanjutnya rapihkan address, city, dan state
select PropertyAddress
from [dbo].[Nashville]
--gunakan substring untuk memisahkan address
SELECT
SUBSTRING(propertyaddress, 1, 19) as Address
from Nashville
--gunakan charindex karena letak delimiter tidak fix
SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)) as Address
from Nashville
--karena masih ada delimiternya, kita kurangkan 1
SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
from Nashville
--pisah 2 kolom address tersebut
SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress)) as Address
from Nashville

alter table Nashville
add AlamatAsli Nvarchar(255);

update Nashville
set AlamatAsli = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table Nashville
add Kota Nvarchar(255);

update Nashville
set Kota = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress))



--sekarang rapihkan owner address
Select OwnerAddress
from Nashville
--gunakan parsename
Select parsename(replace(OwnerAddress, ',','.'),3),
parsename(replace(OwnerAddress, ',','.'),2),
parsename(replace(OwnerAddress, ',','.'),1)
from Nashville

alter table Nashville
add AlamatOwner Nvarchar(255);

update Nashville
set AlamatOwner = parsename(replace(OwnerAddress, ',','.'),3)

alter table Nashville
add KotaOwner Nvarchar(255);

update Nashville
set KotaOwner = parsename(replace(OwnerAddress, ',','.'),2)

alter table Nashville
add NegaraOwner Nvarchar(255);

update Nashville
set NegaraOwner = parsename(replace(OwnerAddress, ',','.'),1)
select *
from Nashville



--rapihkan kolom soldasvacant, ubah Y dan N menjadi Yes dan No
select distinct(SoldAsVacant)
from Nashville

--cek jumlahnya
select distinct(SoldAsVacant), count(soldasvacant) as jumlah
from Nashville
group by SoldAsVacant
order by 2 

--Ubah pakai CASE
select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 End
from Nashville

update Nashville
set soldasvacant = case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 End

select *
from Nashville



--hapus data duplikat

WITH RowNumCTE AS(
select *,
       ROW_NUMBER() OVER (
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					     UniqueID
						 ) row_num
from Nashville
)
Select delete 
from RowNumCTE
Where row_num > 1


-- delete kolom yang tak digunakan

select *
from Nashville
alter table nashville
drop column owneraddress, taxdistrict, propertyaddress
