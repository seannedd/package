c=========================================================
      Program rotate 
c=========================================================
c     December 25, 2006 - Sean A. Nedd 
c     Iowa State University
c
c     Any copies of this program must reference:
c     Sean A. Nedd, Chemistry Department, Iowa State University
c
c     program that rotates around a bond 
c
c     Program use:
c     Script for running is rot
c     Input file must have extension .rot.dat
c     Output is *.data
c
c     Top of input file:
c     #atoms, atomA, atomB,  z rotation angle, #rotations
c     Now list atom type and cartesian coordinates up to #atoms
c     At the end of the file give the number of atoms to rotate
c     then list those atom numbers line by line
c     Note: these atom numbers can be obtained using 
c     A program such as MacMolPlt
c
c     GAMESS input file use ginp and change extension 
c     from .data to .dat
c
      implicit double precision(a-h,o-z)
c
      character*2          atmnam,blank
      character*30         file, fyle
CSN   integer*2            atmtot, atma, atmb
CSN   real                 atnum
CSN   real                 gam, gamint, gamma
c
c     List of terms:
c     iatma  - atom A
c     iatmb  - atom B
c     atmnam - atom name
c     nattot - total number of atoms
c     atnum  - atomic number
c     gamma  - angle of rotation
c     jrot   - number of rotations
c     nnum   - atom to be rotated
c     nrot   - array for atoms to be rotated
c     num    - number of atoms to be rotated
c
      parameter(zero = 0.0D+00, one = 1.0D+00)
      parameter(maxatm = 500)
      parameter(PI = 3.141592653589793238462643D+00)
c
      dimension atmnam(maxatm),atnum(maxatm)
      dimension x(maxatm),y(maxatm),z(maxatm) 
      dimension rotxa(3),rotxb(3),rotxc(3)
      dimension rotya(3),rotyb(3),rotyc(3)
      dimension rotza(3),rotzb(3),rotzc(3)
      dimension nrot(maxatm)
c
      logical debug, gamess
c
      nattot = 3
      iatma = 1
      iatmb = 2
      gamma = 30.0d+00
      jrot = 0
      i = 0
      ii = 0
      iii = 0
      do ii=1,maxatm
       atmnam(ii)='  '
       atnum(ii)=zero
       x(ii)=zero
       y(ii)=zero
       z(ii)=zero
       nrot(ii)=0
      end do
      do iii=1,3
        rotxa(iii)=zero
        rotxb(iii)=zero
        rotxc(iii)=zero
        rotya(iii)=zero
        rotyb(iii)=zero
        rotyc(iii)=zero
        rotza(iii)=zero
        rotzb(iii)=zero
        rotzc(iii)=zero
      end do
c
c     Set output type:
c     gamess = true   -  gives output for gamess
c     gamess = false  -  gives regular coordinates
c
      gamess = .false.
c
c     debug is used to check through the rotations
c
      debug = .false.
c
      call getenv('INPUT',fyle)
      call getenv('OUTPUT',file)
c
      open(unit=5,file=fyle,err=11)
      open(unit=6,file=file,err=11)
c
c     Reads in the total number of atoms
c     and sets the atoms to rotate around
c     All coordinates are then read in
c
      read(5,*) nattot, iatma, iatmb, gamma, jrot
c
c     loop for number required rotations
c
      if(jrot==zero) jrot=(int(360.0d+00/gamma))-1
c
      do i=1,nattot
        read(5,*) atmnam(i),x(i),y(i),z(i)
      end do
c
c     Setting the atomic numbers
c     Setup of atom types gives option for GAMESS input 
c
      call setnum(nattot,atmnam,atnum)
c
c     Sets atma to the origin
c
      write(6,*)"Checking original coordinates"
      call coord(nattot,atmnam,atnum,x,y,z,gamess)
c
c     Let:
      xatma = x(iatma)
      yatma = y(iatma)
      zatma = z(iatma)
c
      do i=1,nattot
        x(i) = x(i) - xatma
        y(i) = y(i) - yatma
        z(i) = z(i) - zatma
      end do
c
      if(debug) then
        write(6,*)"Coordinates after setting at origin"
        call coord(nattot,atmnam,atnum,x,y,z,gamess)
      end if
c
c     rotation around x-axis and y-axis
c     to set atmb on the z-axis
c     Now atma and atmb are on the z axis
c     We can do rotations around the z axis
c     and thus the bond
c
c     rotation matrices are in 1D format
c     theta and phi are analyzed according to quadrant
c
      gam = gamma
      gamint = gam
      gamma = gamma * (PI / 180.0d+00)
c
      theta = abs(atan(y(iatmb)/z(iatmb)))
c
      if(y(iatmb).lt.zero .AND. z(iatmb).gt.zero) then
         theta = 2*PI - theta
      else if(y(iatmb).lt.zero .AND. z(iatmb).lt.zero) then
         theta = PI + theta
      else if(y(iatmb).gt.zero .AND. z(iatmb).lt.zero) then
         theta = PI - theta
      end if
c
c     Rotation in x axis
c
      rotxa(1) = one 
      rotxa(2) = zero 
      rotxa(3) = zero
      rotxb(1) = zero 
      rotxb(2) = cos(theta)
      rotxb(3) = -sin(theta) 
      rotxc(1) = zero
      rotxc(2) = sin(theta) 
      rotxc(3) = cos(theta) 
c
c     Rotation around x-axis
c
      do i=1,nattot
          xatm = x(i)
          yatm = y(i)
          zatm = z(i)
          x(i) = rotxa(1)*xatm
          y(i) = rotxb(2)*yatm + rotxb(3)*zatm
          z(i) = rotxc(2)*yatm + rotxc(3)*zatm
      end do
c
      if(debug) then
        write(6,*)"Coordinates after rotating around x axis"
        call coord(nattot,atmnam,atnum,x,y,z,gamess)
      end if
c
c     Rotation around y-axis
c
      phi = abs(atan(x(iatmb)/z(iatmb)))
c
      if(x(iatmb).gt.zero .AND. z(iatmb).gt.zero) then
         phi = 2*PI - phi
      else if(x(iatmb).lt.zero .AND. z(iatmb).lt.zero) then
         phi = PI - phi
      else if(x(iatmb).gt.zero .AND. z(iatmb).lt.zero) then
         phi = PI + theta
      end if
c
c     Rotation in y axis
c
      rotya(1) = cos(phi)
      rotya(2) = zero 
      rotya(3) = sin(phi) 
      rotyb(1) = zero 
      rotyb(2) = one 
      rotyb(3) = zero 
      rotyc(1) = -sin(phi) 
      rotyc(2) = zero
      rotyc(3) = cos(phi) 
c
      do j=1,nattot
          xatm = x(j)
          yatm = y(j)
          zatm = z(j)
          x(j) = rotya(1)*xatm + rotya(3)*zatm
          y(j) = rotyb(2)*yatm
          z(j) = rotyc(1)*xatm + rotyc(3)*zatm
      end do
c
      if(debug) then
        write(6,*)'Coordinates after rotating around y axis'
        call coord(nattot,atmnam,atnum,x,y,z,gamess)
      else
        write(6,*)'Original coordinates with bond aligned'
        call coord(nattot,atmnam,atnum,x,y,z,gamess)
      end if
c
c     Assumption here:
c     all coordinates to be rotated are either above or below
c     the atma plane. Next method is to specify atoms to be rotated
c     by putting the number of these atoms and what number they appear
c     in the coordinate set. The specification goes at the bottom of
c     the file
c
c     Rotation in z axis
c
      rotza(1) = cos(gamma)
      rotza(2) = -sin(gamma)
      rotza(3) = zero
      rotzb(1) = sin(gamma)
      rotzb(2) = cos(gamma)
      rotzb(3) = zero 
      rotzc(1) = zero
      rotzc(2) = zero
      rotzc(3) = one
c
      read(5,*) num
c
      if(num.le.zero) then
c
c     follow assumption
c
        do j=1,jrot
        do k=1,nattot
         if(z(k).lt.zero) then
          xatm = x(k)
          yatm = y(k)
          zatm = z(k)
          x(k) = rotza(1)*xatm + rotza(2)*yatm
          y(k) = rotzb(1)*xatm + rotzb(2)*yatm
          z(k) = rotzc(3)*zatm
         end if
        end do
        write(6,*)'using assumption'
        call coord(nattot,atmnam,atnum,x,y,z,gamess)
        end do
      else
        do i=1,num
         read(5,*) nnum
         nrot(i) = nnum
        end do
        do j=1,jrot
        do k=1,nattot
          xatm = x(nrot(k))
          yatm = y(nrot(k))
          zatm = z(nrot(k))
          x(nrot(k)) = rotza(1)*xatm + rotza(2)*yatm
          y(nrot(k)) = rotzb(1)*xatm + rotzb(2)*yatm
          z(nrot(k)) = rotzc(3)*zatm
         end do
c     
c     printout of coordinates
c 
         write(6,*) 'Rotation number ',j,', ',gam,' degrees'
         gam = gam + gamint
         call coord(nattot,atmnam,atnum,x,y,z,gamess)
         end do
      end if
c
      close(unit=5)
      write(0,*) 'All done'
c
      continue
c
      close(unit=6)
      goto 12
c
   11 write(0,*) 'some sorta input error'
   12 continue
      stop
      end
c
c
c
c
c     MODULE COORD 
      subroutine coord(nattot,atmnam,atnum,x,y,z,gamess)
c
      implicit double precision(a-h,o-z)
c
CSN   integer*2    atmtot
      character*2  atmnam
CSN   real         atnum
c
      logical gamess
c
      parameter(maxatm = 500)
c
      dimension atmnam(maxatm),atnum(maxatm),
     *          x(maxatm),y(maxatm),z(maxatm)
c
      do k=1,nattot
        if(gamess) then
          write(6,20) atmnam(k),atnum(k),x(k),y(k),z(k)
        else
          write(6,30) atmnam(k),x(k),y(k),z(k)
        end if
      end do
c
   20 format(1x,a2,2x,f4.1,2x,f910.6,2x,f10.6,2x,f10.6)
   30 format(1x,a2,4x,f10.6,3x,f10.6,3x,f10.6)
c
      return
      end
c
c
c
c
c     MODULE SETNUM 
      subroutine setnum(nattot,atmnam,atnum)
c
      implicit double precision(a-h,o-z)
c
      character*2   atmnam
CSN   integer*2     atmtot
CSN   real          atnum
c
      parameter(maxatm = 500)
c
      dimension atmnam(maxatm),atnum(maxatm)
c
      j = 0
      do j=1,nattot
        if(atmnam(j).eq.'H ') atnum(j)=1.0d+00
        if(atmnam(j).eq.'C ') atnum(j)=6.0d+00
        if(atmnam(j).eq.'N ') atnum(j)=7.0d+00
        if(atmnam(j).eq.'O ') atnum(j)=8.0d+00
        if(atmnam(j).eq.'Si') atnum(j)=14.0d+00
        if(atmnam(j).eq.'S ') atnum(j)=16.0d+00
        if(atmnam(j).eq.'X ') atnum(j)=0.0d+00
      end do
c
      return
      end
